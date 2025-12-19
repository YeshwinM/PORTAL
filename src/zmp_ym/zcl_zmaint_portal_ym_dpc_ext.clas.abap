class ZCL_ZMAINT_PORTAL_YM_DPC_EXT definition
  public
  inheriting from ZCL_ZMAINT_PORTAL_YM_DPC
  create public .

public section.
protected section.

  methods ZMAINT_LOGIN_YMS_GET_ENTITY
    redefinition .
  methods ZMAINT_NOTIFICAT_GET_ENTITYSET
    redefinition .
  methods ZMAINT_PLANT_YMS_GET_ENTITYSET
    redefinition .
  methods ZMAINT_WORKORDER_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZMAINT_PORTAL_YM_DPC_EXT IMPLEMENTATION.


method ZMAINT_LOGIN_YMS_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZMAINT_LOGIN_YMS_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
*    IT_NAVIGATION_PATH      =
*  IMPORTING
*    er_entity               =
*    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.

    DATA: ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
          lv_userid  TYPE ZDT_USERNAME_MP_YM,
          lv_pass    TYPE ZDT_PASSWORD_MP_YM,
          ls_res     TYPE ZST_LOGIN_MP_YM.

    " 1. Extract Keys (USERNAME + PASSWORD)
    LOOP AT it_key_tab INTO ls_key_tab.
      TRANSLATE ls_key_tab-name TO UPPER CASE.

      CASE ls_key_tab-name.
        WHEN 'MAINENGINEER'.   " Username
          lv_userid = ls_key_tab-value.

        WHEN 'PASSWORD'.       " Password
          lv_pass   = ls_key_tab-value.
      ENDCASE.
    ENDLOOP.

    " 2. Validate input
    IF lv_userid IS NOT INITIAL AND lv_pass IS NOT INITIAL.

      " 3. Select Data based on BOTH user and password
      SELECT SINGLE * FROM ZDT_MAINPORT_YM
        INTO CORRESPONDING FIELDS OF ls_res
        WHERE main_engineer = lv_userid
          AND password      = lv_pass.

      IF sy-subrc = 0.
        " ---- SUCCESS ----
        er_entity-main_engineer = lv_userid.
        er_entity-password      = lv_pass.
        er_entity-status        = 'Success'.
      ELSE.
        " ---- FAILED ----
        er_entity-main_engineer = lv_userid.
        er_entity-password      = lv_pass.
        er_entity-status        = 'Failed'.
      ENDIF.

    ELSE.
      " Missing input - still return keys
      er_entity-main_engineer = lv_userid.
      er_entity-password      = lv_pass.
      er_entity-status        = 'Failed'.
    ENDIF.

endmethod.


  method ZMAINT_NOTIFICAT_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZMAINT_NOTIFICAT_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
     DATA: lv_engineer TYPE ZDT_USERNAME_MP_YM,
          lt_plant    TYPE ZTT_PLANT_MP_YM,
          lt_notif    TYPE ZTT_NOTIFICATION_MP_YM,
          lt_temp_notif TYPE ZTT_NOTIFICATION_MP_YM. " Temporary table for the loop

    " 1. Get Engineer ID from Filter
    LOOP AT it_filter_select_options INTO DATA(ls_filter).
      IF ls_filter-property = 'Mainengineer' OR ls_filter-property = 'MAIN_ENGINEER'.
        READ TABLE ls_filter-select_options INDEX 1 INTO DATA(ls_so).
        lv_engineer = ls_so-low.
      ENDIF.
    ENDLOOP.

    IF lv_engineer IS NOT INITIAL.


      TRY.
          " 2. Get ALL plants assigned to this engineer
          zmaint_amdp_05=>get_plant_details(
            EXPORTING
              iv_client   = sy-mandt
              iv_engineer = lv_engineer
            IMPORTING
              et_plant    = lt_plant
          ).

          " 3. FIX: Loop through ALL plants, not just the first one
          LOOP AT lt_plant INTO DATA(ls_plant_row).

            CLEAR lt_temp_notif. " Clear previous loop data

            " Get notifications for THIS specific plant
            zmaint_amdp_05=>get_notifications(
              EXPORTING
                iv_client = sy-mandt
                iv_plant  = ls_plant_row-werks
              IMPORTING
                et_notif  = lt_temp_notif
            ).

            " Append these notifications to the final output list
            APPEND LINES OF lt_temp_notif TO et_entityset.

          ENDLOOP.

        CATCH cx_amdp_error.
          " Handle error
      ENDTRY.
    ENDIF.
  endmethod.


  method ZMAINT_PLANT_YMS_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZMAINT_PLANT_YMS_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    DATA: lv_engineer TYPE ZDT_USERNAME_MP_YM,
          lt_plant    TYPE ZTT_PLANT_MP_YM.


    LOOP AT it_filter_select_options INTO DATA(ls_filter).
      IF ls_filter-property = 'MainEngineer' OR ls_filter-property = 'MAIN_ENGINEER'.
        READ TABLE ls_filter-select_options INDEX 1 INTO DATA(ls_so).
        lv_engineer = ls_so-low.
      ENDIF.
    ENDLOOP.


    IF lv_engineer IS NOT INITIAL.
      TRY.
        CALL METHOD zmaint_amdp_05=>get_plant_details
          EXPORTING
            iv_client   = sy-mandt
            iv_engineer = lv_engineer
          IMPORTING
            et_plant    = lt_plant
            .



          et_entityset = lt_plant.

        CATCH cx_amdp_error.

      ENDTRY.
    ENDIF.
  endmethod.


  method ZMAINT_WORKORDER_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZMAINT_WORKORDER_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    DATA: lv_engineer     TYPE ZDT_USERNAME_MP_YM,
          lt_plant        TYPE ZTT_PLANT_MP_YM,
          lt_temp_orders  TYPE ZTT_WORKORDER_MP_YM.

    LOOP AT it_filter_select_options INTO DATA(ls_filter).
      IF ls_filter-property = 'Mainengineer' OR ls_filter-property = 'MAIN_ENGINEER'.
        READ TABLE ls_filter-select_options INDEX 1 INTO DATA(ls_so).
        lv_engineer = ls_so-low.
      ENDIF.
    ENDLOOP.

    IF lv_engineer IS NOT INITIAL.


      TRY.

          zmaint_amdp_05=>get_plant_details(
            EXPORTING
              iv_client   = sy-mandt
              iv_engineer = lv_engineer
            IMPORTING
              et_plant    = lt_plant
          ).


          LOOP AT lt_plant INTO DATA(ls_plant_row).

            CLEAR lt_temp_orders.


            zmaint_amdp_05=>get_work_orders(
              EXPORTING
                iv_client = sy-mandt
                iv_plant  = ls_plant_row-werks
              IMPORTING
                et_orders = lt_temp_orders
            ).

            APPEND LINES OF lt_temp_orders TO et_entityset.

          ENDLOOP.

        CATCH cx_amdp_error.

      ENDTRY.
    ENDIF.
  endmethod.
ENDCLASS.

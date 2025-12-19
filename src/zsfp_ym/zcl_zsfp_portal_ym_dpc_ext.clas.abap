class ZCL_ZSFP_PORTAL_YM_DPC_EXT definition
  public
  inheriting from ZCL_ZSFP_PORTAL_YM_DPC
  create public .

public section.
protected section.

  methods ZSFP_LOGIN_YMSET_GET_ENTITY
    redefinition .
  methods ZSFP_PLANORDER_Y_GET_ENTITYSET
    redefinition .
  methods ZSFP_PRODORDER_Y_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZSFP_PORTAL_YM_DPC_EXT IMPLEMENTATION.


  method ZSFP_LOGIN_YMSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZSFP_LOGIN_YMSET_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    DATA: lv_user TYPE ZDT_SHOPFLOOR_YM-empid,
        lv_password TYPE ZDT_SHOPFLOOR_YM-PASSWORD,
        lv_message  TYPE string,
        lt_key_tab  TYPE /iwbep/t_mgw_tech_pairs,
        ls_key      TYPE /iwbep/s_mgw_tech_pair,
        ls_login    TYPE ZDT_SHOPFLOOR_YM.

  " Get key values from URL
  lt_key_tab = io_tech_request_context->get_keys( ).

  LOOP AT lt_key_tab INTO ls_key.
    CASE ls_key-name.
      WHEN 'EMPID'.
        lv_user = ls_key-value.
      WHEN 'PASSWORD'.
        lv_password = ls_key-value.
    ENDCASE.
  ENDLOOP.

  " Check in the login table
  SELECT SINGLE * INTO @ls_login FROM ZDT_SHOPFLOOR_YM
    WHERE EMPID = @lv_user AND PASSWORD = @lv_password.

  IF sy-subrc = 0.
    lv_message = 'Login Successful'.
  ELSE.
    lv_message = 'Invalid Credentials'.
  ENDIF.

  " Return the result
  er_entity = VALUE #( EMPID = lv_user PASSWORD = lv_message ).
  endmethod.


  method ZSFP_PLANORDER_Y_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZSFP_PLANORDER_Y_GET_ENTITYSET
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
     DATA: lt_amdp_data TYPE ZTT_PLANORDER_SFP_YM.
    CALL METHOD zsfp_portal_ym=>get_planned_orders
      EXPORTING
        iv_client = sy-mandt
      IMPORTING
        et_orders = lt_amdp_data
        .
    et_entityset = lt_amdp_data.
    IF it_filter_select_options IS NOT INITIAL.
      CALL METHOD /iwbep/cl_mgw_data_util=>filtering
        EXPORTING
          it_select_options = it_filter_select_options
        CHANGING
          ct_data           = et_entityset.
    ENDIF.
  endmethod.


  method ZSFP_PRODORDER_Y_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZSFP_PRODORDER_Y_GET_ENTITYSET
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
     DATA: lt_amdp_data TYPE ZTT_PRODORDER_SFP_YM.
CALL METHOD zsfp_portal_ym=>get_prod_orders
  EXPORTING
    iv_client = sy-mandt
  IMPORTING
    et_orders = lt_amdp_data
    .


    et_entityset = lt_amdp_data.


    IF it_filter_select_options IS NOT INITIAL.
      CALL METHOD /iwbep/cl_mgw_data_util=>filtering
        EXPORTING
          it_select_options = it_filter_select_options
        CHANGING
          ct_data           = et_entityset.
    ENDIF.
  endmethod.
ENDCLASS.

class ZCL_ZEHSM_PORTAL_YM_DPC_EXT definition
  public
  inheriting from ZCL_ZEHSM_PORTAL_YM_DPC
  create public .

public section.
protected section.

  methods ZEHSM_INCIDENT_Y_GET_ENTITYSET
    redefinition .
  methods ZEHSM_LOGIN_YMSE_GET_ENTITY
    redefinition .
  methods ZEHSM_PROFILE_YM_GET_ENTITY
    redefinition .
  methods ZEHSM_RISK_YMSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZEHSM_PORTAL_YM_DPC_EXT IMPLEMENTATION.


  method ZEHSM_INCIDENT_Y_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZEHSM_INCIDENT_Y_GET_ENTITYSET
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
    DATA: lv_empid    TYPE persno,
        lt_inc      TYPE ZTT_INCIDENT_EHSM_YM,
        ls_inc      TYPE ZST_INCIDENT_EHSM_YM.

  LOOP AT it_filter_select_options INTO DATA(ls_filter).
    IF ls_filter-property = 'EmployeeId'.
      READ TABLE ls_filter-select_options INTO DATA(ls_sel) INDEX 1.
      IF sy-subrc = 0.
        lv_empid = ls_sel-low.
      ENDIF.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF lv_empid IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_empid
      IMPORTING
        output = lv_empid.
  ENDIF.

  IF lv_empid IS INITIAL.
    RETURN.
  ENDIF.


CALL METHOD ZEHSM_PORTAL_YMA=>get_incidents
  EXPORTING
    iv_client     = sy-mandt
    iv_employeeid = lv_empid
  IMPORTING
    et_incidents    = lt_inc
    .


  LOOP AT lt_inc INTO ls_inc.
    APPEND ls_inc TO et_entityset.
  ENDLOOP.
  endmethod.


  method ZEHSM_LOGIN_YMSE_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZEHSM_LOGIN_YMSE_GET_ENTITY
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
    DATA: lv_employee_id TYPE ZDE_USERNAME_EHSM_YM,
      lv_empid type pernr_d,
          lv_password  TYPE ZDE_PASSWORD_EHSM_YM.


    LOOP AT it_key_tab INTO DATA(ls_key).
      CASE ls_key-name.
        WHEN 'EmployeeId'.
          lv_employee_id = ls_key-value.
        WHEN 'Password'.
          lv_password = ls_key-value.
      ENDCASE.
    ENDLOOP.
lv_empid = |{ lv_employee_id WIDTH = 8 ALIGN = RIGHT PAD = '0' }|.
    SELECT SINGLE * FROM ZDT_EHSMPORT_YM INTO @DATA(ls_auth)
      WHERE EMPLOYEE_ID = @lv_empid
       AND PASSWORD = @lv_password.

    CLEAR er_entity.
    IF sy-subrc = 0.
      " Login success
      er_entity-EMPLOYEE_ID        = lv_empid.
      er_entity-PASSWORD = lv_password.
      er_entity-STATUS          = 'Success'.

    ELSE.
      " Login failed
      er_entity-EMPLOYEE_ID        = lv_empid.
      er_entity-PASSWORD = ''.
      er_entity-STATUS          = 'Invalid'.

    ENDIF.
  endmethod.


  method ZEHSM_PROFILE_YM_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZEHSM_PROFILE_YM_GET_ENTITY
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
     DATA: ls_entity     TYPE ZST_PROFILE_EHSM_YM,
        lt_profile    TYPE ZTT_PROFILE_EHSM_YM,
        lv_employeeid TYPE ZDE_USERNAME_EHSM_YM,
        lv_empid type pernr_d,
        ls_key_tab    TYPE /iwbep/s_mgw_name_value_pair.

  READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'EmployeeId'.
  IF sy-subrc = 0.
    lv_employeeid = ls_key_tab-value.
  ENDIF.

  IF lv_employeeid IS INITIAL.
    RETURN.
  ENDIF.
 lv_empid = |{ lv_employeeid WIDTH = 8 ALIGN = RIGHT PAD = '0' }|.

  CALL METHOD ZEHSM_PORTAL_YMA=>get_profile
    EXPORTING
      iv_client     = sy-mandt
      iv_employeeid = lv_empid
    IMPORTING
      et_profile    = lt_profile
      .

  READ TABLE lt_profile INTO ls_entity INDEX 1.
  IF sy-subrc = 0.
    er_entity = ls_entity.
  ENDIF.
  endmethod.


  method ZEHSM_RISK_YMSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZEHSM_RISK_YMSET_GET_ENTITYSET
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
    DATA: lv_empid TYPE persno,
        lt_risk  TYPE ZTT_RISK_EHSM_YM,
        ls_risk  TYPE ZST_RISK_EHSM_YM.

  LOOP AT it_filter_select_options INTO DATA(ls_filter).
    IF ls_filter-property = 'EmployeeId'.
      READ TABLE ls_filter-select_options INTO DATA(ls_sel) INDEX 1.
      IF sy-subrc = 0.
        lv_empid = ls_sel-low.
      ENDIF.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF lv_empid IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_empid
      IMPORTING
        output = lv_empid.
  ENDIF.

  IF lv_empid IS INITIAL.
    RETURN.
  ENDIF.

CALL METHOD ZEHSM_PORTAL_YMA=>get_risks
  EXPORTING
    iv_client     = sy-mandt
    iv_employeeid = lv_empid
  IMPORTING
    et_risks      = lt_risk
    .

  LOOP AT lt_risk INTO ls_risk.
    APPEND ls_risk TO et_entityset.
  ENDLOOP.
  endmethod.
ENDCLASS.

class ZCL_ZEMP_PORTAL_YM_DPC_EXT definition
  public
  inheriting from ZCL_ZEMP_PORTAL_YM_DPC
  create public .

public section.
protected section.

  methods ZEMP_LOGIN_YMSET_GET_ENTITY
    redefinition .
  methods ZEMP_PAYSLIP_YMS_GET_ENTITY
    redefinition .
  methods ZEMP_PROFILE_YMS_GET_ENTITY
    redefinition .
  methods ZEMP_LEAVE_YMSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZEMP_PORTAL_YM_DPC_EXT IMPLEMENTATION.


  method ZEMP_LEAVE_YMSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->ZEMP_LEAVE_YMSET_GET_ENTITYSET
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
   DATA: lv_emp_id     TYPE persno,
        ls_filter     TYPE /iwbep/s_mgw_select_option,
        ls_selopt     TYPE /iwbep/s_cod_select_option.

  "---------------------------------------------------------------
  " 1. Read EmpId from Filters
  "---------------------------------------------------------------
  LOOP AT it_filter_select_options INTO ls_filter.
    IF ls_filter-property = 'EmpId'.   "OData Property (case-sensitive)

      READ TABLE ls_filter-select_options INTO ls_selopt INDEX 1.
      IF sy-subrc = 0.
        lv_emp_id = ls_selopt-low.
      ENDIF.

    ENDIF.
  ENDLOOP.

  "---------------------------------------------------------------
  " 2. Mandatory Input Validation
  "---------------------------------------------------------------
  IF lv_emp_id IS INITIAL.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid  = /iwbep/cx_mgw_busi_exception=>business_error
        message = 'EmpId is mandatory'.
  ENDIF.

  "---------------------------------------------------------------
  " 3. ALPHA Conversion
  "---------------------------------------------------------------
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING input = lv_emp_id
    IMPORTING output = lv_emp_id.

  "---------------------------------------------------------------
  " 4. Fetch Leave Data from PA2001
  "---------------------------------------------------------------
  SELECT
      a~pernr   AS emp_id,
      a~begda   AS start_date,
      a~endda   AS end_date,
      a~awart   AS aatype,
      a~abrtg   AS pay_days,
      a~abrst   AS pay_hr,
      a~kaltg   AS cal_days
    FROM pa2001 AS a
    WHERE a~pernr = @lv_emp_id
      AND a~awart IN ('0300', '0720')   "Your required leave types
    INTO CORRESPONDING FIELDS OF TABLE @et_entityset.

ENDMETHOD.


  method ZEMP_LOGIN_YMSET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZEMP_LOGIN_YMSET_GET_ENTITY
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
 "---------------------------------------------------------------
  " 1. Read Keys From IT_KEY_TAB
  "---------------------------------------------------------------
  DATA(lv_emp_id)    = VALUE char10( it_key_tab[ name = 'EmpId' ]-value OPTIONAL ).
  DATA(lv_password)  = VALUE char20( it_key_tab[ name = 'Password' ]-value OPTIONAL ).

  "Convert EmpId using SAP ALPHA format
  DATA lv_emp_no TYPE persno.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_emp_id
    IMPORTING
      output = lv_emp_no.

  "Structure for DB read
  DATA: ls_login TYPE zts_emp_login_s.

  "---------------------------------------------------------------
  " 2. Validate Employee-ID from PA0001
  "---------------------------------------------------------------
  SELECT SINGLE pernr
    INTO @ls_login-emp_id
    FROM pa0001
    WHERE pernr = @lv_emp_no.

  "Set Emp ID in OData output
  er_entity-emp_id = lv_emp_no.

  IF sy-subrc <> 0.
    er_entity-status = 'Incorrect Employee ID'.
    RETURN.
  ENDIF.

  "---------------------------------------------------------------
  " 3. Validate Password From Custom Z Table
  "---------------------------------------------------------------
  SELECT SINGLE emp_id, password
    FROM zts_emp_login_d
    INTO CORRESPONDING FIELDS OF @ls_login
    WHERE emp_id   = @lv_emp_no
      AND password = @lv_password.

  IF sy-subrc = 0.
    er_entity-status = 'Login Successful'.
  ELSE.
    er_entity-status = 'Incorrect Password'.
  ENDIF.

  endmethod.


  method ZEMP_PAYSLIP_YMS_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZEMP_PAYSLIP_YMS_GET_ENTITY
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
DATA: ls_payslip      TYPE zts_emp_payslip_s,
        lt_payslip      TYPE zts_emp_payslip_t,
        lv_outputparams TYPE sfpoutputparams,
        lv_docparams    TYPE sfpdocparams,
        lv_fm_name      TYPE funcname,
        lv_formoutput   TYPE fpformoutput,
        lv_pdf          TYPE xstring.

  DATA: ls_key    TYPE /iwbep/s_mgw_name_value_pair,
        lv_pernr  TYPE persno,
        lv_mobno  TYPE char20.   " Temporary for VDSK1

  "---------------------------------------------------------
  " 2. Read EmpId Key
  "---------------------------------------------------------
  READ TABLE it_key_tab WITH KEY name = 'EmpId' INTO ls_key.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  lv_pernr = ls_key-value.

  "---------------------------------------------------------
  " 3. Fetch PA0001 Data
  "---------------------------------------------------------
  SELECT SINGLE
         pernr,
         bukrs,
         werks,
         plans,
         persg,
         persk,
         orgeh,
         vdsk1,
         sname
    FROM pa0001
    WHERE pernr = @lv_pernr
      AND endda = '99991231'
    INTO (
      @ls_payslip-emp_id,
      @ls_payslip-comp_code,
      @ls_payslip-p_area,
      @ls_payslip-pos,
      @ls_payslip-emp_grp,
      @ls_payslip-emp_sgrp,
      @ls_payslip-org_key,
      @lv_mobno,
      @ls_payslip-server_name
    ).

  ls_payslip-mob_no = lv_mobno.

  "---------------------------------------------------------
  " 4. Fetch PA0008 – Basic Pay
  "---------------------------------------------------------
  SELECT SINGLE
         trfar   AS pst,
         trfgb   AS psa,
         trfgr   AS psg,
         trfst   AS psl,
         waers   AS currency,
         divgv   AS work_hr,
         ansal   AS annual_salary,
         lga01   AS wage_type,
         bet01   AS wt_amt
    FROM pa0008
    WHERE pernr = @lv_pernr
      AND endda = '99991231'
    INTO CORRESPONDING FIELDS OF @ls_payslip.

  "---------------------------------------------------------
  " 5. Fetch PA0009 – Bank Information
  "---------------------------------------------------------
  SELECT SINGLE
         banks AS bank,
         bankl AS bank_no,
         zlsch AS pay_mode
    FROM pa0009
    WHERE pernr = @lv_pernr
      AND endda = '99991231'
    INTO CORRESPONDING FIELDS OF @ls_payslip.

  APPEND ls_payslip TO lt_payslip.

  "---------------------------------------------------------
  " 6. Adobe Form → PDF Generation
  "---------------------------------------------------------
  CLEAR lv_outputparams.
  lv_outputparams-getpdf = 'X'.

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = lv_outputparams.

  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = 'ZMAH_EMP_PAYSLIP_MAH'
    IMPORTING
      e_funcname = lv_fm_name.

  CALL FUNCTION lv_fm_name
    EXPORTING
      /1bcdwb/docparams = lv_docparams
      et_data           = lt_payslip
    IMPORTING
      /1bcdwb/formoutput = lv_formoutput.

  CALL FUNCTION 'FP_JOB_CLOSE'.

  lv_pdf = lv_formoutput-pdf.

  "---------------------------------------------------------
  " 7. Set OData Output
  "---------------------------------------------------------
  MOVE-CORRESPONDING ls_payslip TO er_entity.
  er_entity-pdf = lv_pdf.

ENDMETHOD.


  method ZEMP_PROFILE_YMS_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->ZEMP_PROFILE_YMS_GET_ENTITY
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
    DATA: emp_no TYPE persno.

  READ TABLE it_key_tab INTO DATA(ls_key) WITH KEY name = 'EmpNo'.

  IF sy-subrc = 0.
    emp_no = ls_key-value.
  ELSE.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid  = /iwbep/cx_mgw_busi_exception=>business_error
        message = 'Employee Number not provided in request'.
  ENDIF.


  "-----------------------------------------------------------------
  " 2. Convert EmpNo Using ALPHA Input
  "-----------------------------------------------------------------
  DATA lv_emp_id TYPE persno.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = emp_no
    IMPORTING
      output = lv_emp_id.


  "-----------------------------------------------------------------
  " 3. Fetch Employee Profile From PA0001, PA0002, PA0006
  "-----------------------------------------------------------------
  SELECT SINGLE
        A~pernr  AS emp_no,
        A~orgeh  AS org_unit,
        A~persg  AS emp_grp,
        A~plans  AS pos,
        A~sbmod  AS admin_grp,
        A~begda  AS b_date,
        A~endda  AS e_date,
        A~bukrs  AS comp_code,
        A~werks  AS pers_area,
        A~persk  AS emp_sg,
        A~vdsk1  AS org_key,
        A~btrtl  AS pers_sarea,
        A~abkrs  AS payroll_area,
        B~nachn  AS l_name,
        B~vorna  AS f_name,
        B~anred  AS addr_key,
        B~gesch  AS gender,
        B~natio  AS nation,
        B~sprsl  AS l_key,
        C~ort01  AS city,
        C~pstlz  AS postal,
        C~locat  AS area
    INTO CORRESPONDING FIELDS OF @er_entity
    FROM pa0001 AS A
      INNER JOIN pa0002 AS B ON A~pernr = B~pernr
      INNER JOIN pa0006 AS C ON A~pernr = C~pernr
    WHERE A~pernr = @lv_emp_id.

  "-----------------------------------------------------------------
  " 4. Handle Not Found
  "-----------------------------------------------------------------
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid  = /iwbep/cx_mgw_busi_exception=>business_error
        message = |No profile data found for Employee { emp_no }|.
  ENDIF.

ENDMETHOD.
ENDCLASS.

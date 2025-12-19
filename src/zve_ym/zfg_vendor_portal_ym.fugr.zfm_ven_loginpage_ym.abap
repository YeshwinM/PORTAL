FUNCTION ZFM_VEN_LOGINPAGE_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_USERNAME) TYPE  LIFNR
*"     VALUE(IV_PASSWORD) TYPE  CHAR20
*"  EXPORTING
*"     VALUE(EV_STATUS) TYPE  CHAR10
*"----------------------------------------------------------------------
DATA: ls_lfa1  TYPE lfa1,
        ls_login TYPE ZDT_VEN_YM.

  SELECT SINGLE * INTO ls_lfa1
    FROM lfa1
    WHERE lifnr = iv_username.
  IF sy-subrc <> 0.
    ev_status = 'LOG FAILED'.
    RETURN.
  ENDIF.
  SELECT SINGLE * INTO ls_login
    FROM ZDT_VEN_YM
    WHERE lifnr = iv_username.
  IF sy-subrc <> 0.
    ev_status = 'LOG FAILED'.
    RETURN.
  ENDIF.
  IF ls_login-pass = iv_password.
    ev_status = 'SUCCESS'.
  ELSE.
    ev_status = 'FAILED'.
  ENDIF.




ENDFUNCTION.

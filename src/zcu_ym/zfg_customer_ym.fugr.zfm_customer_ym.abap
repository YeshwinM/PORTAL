FUNCTION ZFM_CUSTOMER_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(USER_ID) TYPE  ZST_CUSLOGINST-USERID
*"     VALUE(PASSWORD) TYPE  ZST_CUSLOGINST-PASSWORD
*"  EXPORTING
*"     VALUE(MESSAGE) TYPE  ZST_CUSLOGINST-MESSAGE
*"     VALUE(STATUS) TYPE  ZST_CUSLOGINST-STATUS
*"----------------------------------------------------------------------




DATA: lv_kunnr     TYPE kunnr,
        lv_db_passwd TYPE ZDB_CULOG-PASSWORD.  "match data type to table
  "Step 1: Check if customer exists in standard table (KNA1)
  SELECT SINGLE kunnr
    INTO lv_kunnr
    FROM kna1
    WHERE kunnr = USER_ID.
  IF sy-subrc <> 0.
    status  = 'E'.
    message = 'Customer ID not found in system (KNA1).'.
    RETURN.
  ENDIF.
  "Step 2: Check credentials in custom Z table
  SELECT SINGLE password
    INTO lv_db_passwd
    FROM ZDB_CULOG
    WHERE USERID = USER_ID.
  IF sy-subrc <> 0.
    status  = 'E'.
    message = 'CustomerId doesnt exists.'.
    RETURN.
  ENDIF.
  "Step 3: Compare passwords
  IF lv_db_passwd = password.
    status  = 'S'.
    message = 'Login successful.'.
  ELSE.
    status  = 'E'.
    message = 'Invalid password.'.
  ENDIF.
ENDFUNCTION.

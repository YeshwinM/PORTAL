FUNCTION ZFM_INVOICEPDF_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INVOICE_NO) TYPE  VBELN_VF
*"  EXPORTING
*"     VALUE(INVOICE_PDF) TYPE  STRING
*"----------------------------------------------------------------------
DATA:
      inv_formoutput TYPE fpformoutput.
  SUBMIT ZP_CUST_INVOICE_YM

    WITH p_invo = INVOICE_NO
    AND RETURN.
  " Import Adobe form result from memory
  IMPORT lv_form TO inv_formoutput FROM MEMORY ID 'C_MEMORY'.
  " Convert XSTRING to Base64 STRING
  CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
    EXPORTING
      input  = inv_formoutput-pdf
    IMPORTING
      output = INVOICE_PDF.




ENDFUNCTION.

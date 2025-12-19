FUNCTION ZFM_CUS_PAYMENT_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CUSTOMER_ID) TYPE  KUNNR
*"  EXPORTING
*"     VALUE(PAYMENT) TYPE  ZTT_CUS_PAYMENT_YM
*"----------------------------------------------------------------------
DATA:
        lv_age TYPE i,
      lv_today TYPE sy-datum.
lv_today = sy-datum.
SELECT
    vbak~vbeln      AS bill_num,       " Sales Document
    vbak~erdat      AS doc_date,       " Creation Date
    vbak~audat      AS due_date,       " Document Date (used as Due Date)
    vbak~netwr      AS amount,         " Net value
    vbak~waerk      AS currency,       " Currency
    vbpa~kunnr      AS customer_id,        " Customer Number
    kna1~name1      AS cust_name,      " Customer Name
    vbak~auart      AS doc_type,       " Sales Doc Type
    vbak~bukrs_vf   AS company_code  " Company Code for Billing
      " Business Area
INTO TABLE @PAYMENT
FROM vbak
  INNER JOIN vbpa ON vbak~vbeln = vbpa~vbeln
  INNER JOIN kna1 ON vbpa~kunnr = kna1~kunnr
WHERE vbpa~parvw = 'AG'
  AND vbpa~kunnr = @customer_id.
" Now calculate aging and update AGE column
LOOP AT PAYMENT INTO DATA(ls_item).
  ls_item-age = lv_today - ls_item-doc_date.
  MODIFY PAYMENT FROM ls_item TRANSPORTING age.
ENDLOOP.




ENDFUNCTION.

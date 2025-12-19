FUNCTION ZFM_CUS_CREDEB_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CUSTOMER_ID) TYPE  KUNNR
*"  EXPORTING
*"     VALUE(CREDIT_DEBIT) TYPE  ZTT_CUS_CREDEB_YM
*"----------------------------------------------------------------------
SELECT
    vbrk~vbeln     AS memo_num,
    vbrk~erdat     AS doc_date,
    vbrk~fkdat     AS bill_date,
    vbrk~kunag     AS customer_id,
    kna1~name1     AS cust_name,
    vbrk~netwr     AS amount,
    vbrk~waerk     AS currency,
    vbrk~fkart     AS doc_type,
    vbrk~vkorg     AS sales_org,
    vbrk~vtweg     AS dist_chnl,
    vbrk~spart     AS division,
    CASE vbrk~fkart
      WHEN 'G2' THEN 'C'
      WHEN 'L2' THEN 'D'
    END           AS status
INTO TABLE @CREDIT_DEBIT
FROM vbrk
INNER JOIN kna1 ON vbrk~kunag = kna1~kunnr
WHERE vbrk~kunag = @customer_id
  AND vbrk~fkart IN ('G2', 'L2').




ENDFUNCTION.

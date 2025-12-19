FUNCTION ZFM_CUS_ENQUIRY_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CUSTOMER_ID) TYPE  KUNNR
*"  EXPORTING
*"     VALUE(ENQUIRY) TYPE  ZDT_CUS_ENQUIRY_YM
*"----------------------------------------------------------------------
SELECT

  vbak~vbeln        AS Enq_num,
  vbak~erdat        AS doc_date,
  vbak~kunnr        AS cust_id,
  kna1~name1        AS cust_name,
  vbak~auart        AS doc_type,
  vbak~ernam        AS created_by,
  vbak~netwr        AS net_value,
  vbak~waerk        AS currency,
  vbak~vkorg        AS sales_org,
  vbap~matnr        AS matnr,
   vbap~arktx        AS mat_desc,
vbap~kwmeng       AS quant,
vbap~vrkme        AS unit

INTO TABLE @ENQUIRY
FROM vbak
INNER JOIN vbap ON vbap~vbeln = vbak~vbeln
LEFT JOIN kna1 ON kna1~kunnr = vbak~kunnr
WHERE kna1~kunnr = @CUSTOMER_ID.




ENDFUNCTION.

FUNCTION ZFM_CUS_SALES_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CUSTOMER_ID) TYPE  KUNNR
*"  EXPORTING
*"     VALUE(SALES) TYPE  ZTT_CUS_SALES_YM
*"----------------------------------------------------------------------
SELECT
  vbak~vbeln        AS inq_num,
  vbak~kunnr       AS cus_number,
  vbak~ernam        AS created_by,
  vbak~auart        AS doc_type,
  vbak~erdat        AS doc_date,
  vbak~waerk        AS currency,
  vbap~matnr      AS material_number,
  vbap~arktx       AS description,
  vbap~kwmeng        AS order_quantity,
  vbap~netpr        AS price_per_unit,
  vbap~netwr        AS item_net_vale,
  vbap~vrkme       AS  unit
INTO TABLE @sales
FROM vbak
INNER JOIN vbap ON vbap~vbeln = vbak~vbeln
LEFT JOIN kna1 ON kna1~kunnr = vbak~kunnr
WHERE kna1~kunnr = @customer_id.




ENDFUNCTION.

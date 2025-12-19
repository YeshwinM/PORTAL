FUNCTION ZFM_CUS_DELIVERY_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CUSTOMER_ID) TYPE  KUNNR
*"  EXPORTING
*"     VALUE(DELIVERY) TYPE  ZTT_CUS_DELIVERY_YM
*"----------------------------------------------------------------------
SELECT
  likp~vbeln     AS deliv_num,
  likp~erdat     AS doc_date,
  likp~ernam     AS created_by,
  likp~wadat_ist AS ship_date,
  likp~kunnr     AS cust_id,
  kna1~name1     AS cust_name,
  likp~wbstk     AS deliv_status,
  vbak~vkorg     AS sales_org,
  vbak~vtweg     AS dist_chnl,
  vbak~spart     AS division,
  lips~matnr     AS matnr,
  lips~arktx     AS mat_desc,
  lips~lfimg     AS quant,
  lips~vrkme     AS unit,
  lips~posnr     AS dlv_item
INTO TABLE @DELIVERY
FROM likp
INNER JOIN lips ON likp~vbeln = lips~vbeln
INNER JOIN vbak ON lips~vgbel = vbak~vbeln
INNER JOIN kna1 ON likp~kunnr = kna1~kunnr
WHERE likp~kunnr = @customer_id.




ENDFUNCTION.

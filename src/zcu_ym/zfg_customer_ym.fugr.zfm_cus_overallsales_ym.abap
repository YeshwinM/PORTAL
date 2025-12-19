FUNCTION ZFM_CUS_OVERALLSALES_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CUSTOMER_ID) TYPE  KUNNR
*"  EXPORTING
*"     VALUE(OVERALL_SALES) TYPE  ZTT_CUS_OVERALLSALES_YM
*"----------------------------------------------------------------------
DATA: lt_data TYPE ZCUSTOMERTT_OVERALL_SALES.
  SELECT
    vbrp~matnr         AS material_number,
    vbrp~arktx         AS material_description,
    vbrk~waerk         AS currency,
    vbrk~fkdat         AS billing_date,
    vbrp~netwr         AS net_value,
    vbrk~fkart         AS billing_type,
    vbpa~kunnr         AS customer_number,
    vbrk~vkorg         AS sales_org,
    vbrk~spart         AS division,
*    mara~matkl         AS material_group,
    vbrp~fkimg         AS quantity_sold,
    vbrp~vrkme         AS sales_unit
  FROM vbrk
    INNER JOIN vbrp ON vbrk~vbeln = vbrp~vbeln
    INNER JOIN vbpa ON vbpa~vbeln = vbrk~vbeln AND vbpa~parvw = 'AG'
*    LEFT JOIN mara  ON vbrp~matnr = mara~matnr
  WHERE vbrk~fkart = 'F2'
    AND ( vbpa~kunnr = @customer_id OR @customer_id IS INITIAL )
  INTO CORRESPONDING FIELDS OF TABLE @OVERALL_SALES.
  OVERALL_SALES = OVERALL_SALES.




ENDFUNCTION.

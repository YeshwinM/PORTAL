FUNCTION ZFM_CUS_INVOICEFM_YM .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CUSTOMER_ID) TYPE  KUNAG
*"  EXPORTING
*"     VALUE(INVOICE_DATA) TYPE  ZTT_CUS_INVOICETT_YM
*"----------------------------------------------------------------------
DATA: lt_vbrk     TYPE TABLE OF vbrk,
        lt_vbrp     TYPE TABLE OF vbrp,
        ls_invoice  TYPE ZDT_CUSTINVOICESTRUCT,
        ls_vbrk     TYPE vbrk,
        ls_vbrp     TYPE vbrp.
  CLEAR invoice_data.
  SELECT * FROM vbrk
    INTO TABLE lt_vbrk
    WHERE kunag = customer_id.
  LOOP AT lt_vbrk INTO ls_vbrk.
    SELECT * FROM vbrp
      INTO TABLE lt_vbrp
      WHERE vbeln = ls_vbrk-vbeln.
    LOOP AT lt_vbrp INTO ls_vbrp.
      CLEAR ls_invoice.
      ls_invoice-customer_id   = ls_vbrk-kunag.
      ls_invoice-invoice_no    = ls_vbrk-vbeln.
      ls_invoice-invoice_date  = ls_vbrk-fkdat.
      ls_invoice-net_value     = ls_vbrk-netwr.
      ls_invoice-currency      = ls_vbrk-waerk.
      ls_invoice-sales_org     = ls_vbrk-vkorg.
      ls_invoice-billing_type  = ls_vbrk-fkart.
      ls_invoice-material_no   = ls_vbrp-matnr.
      ls_invoice-material_desc = ls_vbrp-arktx.
      ls_invoice-quantity      = ls_vbrp-fkimg.
      ls_invoice-unit          = ls_vbrp-vrkme.
      ls_invoice-ref_doc       = ls_vbrp-vbelv.
      ls_invoice-net_item      = ls_vbrp-netwr.
      APPEND ls_invoice TO invoice_data.
    ENDLOOP.
  ENDLOOP.
ENDFUNCTION.

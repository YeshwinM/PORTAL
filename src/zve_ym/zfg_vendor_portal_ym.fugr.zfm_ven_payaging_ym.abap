FUNCTION ZFM_VEN_PAYAGING_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DOC) TYPE  LIFNR
*"  EXPORTING
*"     VALUE(EV_VEN_PAA) TYPE  ZTT_VEN_PAYAGING_YM
*"----------------------------------------------------------------------
Data: lv_lifnr TYPE lifnr,
      lv_days TYPE i,
      ls_line TYPE ZST_VEN_PAYAGING_YM.

LV_LIFNR = IV_DOC.

SELECT BSEG~BELNR,
  BKPF~BLDAT,
  BSEG~WRBTR
  FROM BKPF
  INNER JOIN BSEG ON BKPF~BUKRS = BSEG~BUKRS AND
  BKPF~GJAHR = BSEG~GJAHR AND
  BKPF~BELNR = BSEG~BELNR
  INTO (@LS_LINE-BELNR,@LS_LINE-BLDAT,@LS_LINE-WRBTR)
  WHERE BSEG~LIFNR = @IV_DOC.
  "AND BSEG~KOART = 'k'.

  DATA(lv_due_date) = ls_line-bldat + 30.
    ls_line-dats = lv_due_date. " Simulated due date = billing date + 30
    lv_days = abs( sy-datum - lv_due_date ).
    ls_line-aging = lv_days.


    APPEND  ls_line TO EV_VEN_PAA.
    CLEAR ls_line.


ENDSELECT.




ENDFUNCTION.

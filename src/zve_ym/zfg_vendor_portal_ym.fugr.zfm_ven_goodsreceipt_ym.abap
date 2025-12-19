FUNCTION ZFM_VEN_GOODSRECEIPT_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DOC) TYPE  LIFNR
*"  EXPORTING
*"     VALUE(EV_VEN_GR) TYPE  ZTT_VEN_RECEIPT_YM
*"----------------------------------------------------------------------

DATA: lt_result TYPE ZTT_VEN_RECEIPT_YM.


  SELECT
    MKPF~MBLNR,
    MKPF~MJAHR,
    MKPF~BUDAT,
    mkpf~bldat,
    MKPF~BLART,
    MKPF~USNAM,
    MSEG~ZEILE,
    MSEG~EBELN,
    MSEG~EBELP,
    MSEG~BWART,
    MSEG~MENGE,
    MSEG~MEINS,
    MSEG~WERKS,
    MSEG~LGORT,
    MSEG~MATNR,
    MSEG~LIFNR

    INTO TABLE @lt_result
    FROM MKPF
    INNER JOIN MSEG ON MKPF~MBLNR = MSEG~MBLNR
    "mseg~gjahr = mkpf~gjahr
     "EKPO~EBELN = MSEG~EBELN
    WHERE mseg~LIFNR = @iv_DOC
    AND MSEG~BWART = '101'.

  ev_ven_gr = lt_result.



ENDFUNCTION.

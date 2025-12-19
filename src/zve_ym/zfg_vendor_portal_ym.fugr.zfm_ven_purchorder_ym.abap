FUNCTION ZFM_VEN_PURCHORDER_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DOC) TYPE  LIFNR
*"  EXPORTING
*"     VALUE(EV_VEN_PO) TYPE  ZTT_VEN_PURORDER_YM
*"----------------------------------------------------------------------
DATA: lt_result TYPE ZTT_VEN_PURORDER_YM.


  SELECT
ekko~ebeln,
    ekko~bsart,
    ekko~ekorg,
    ekko~ekgrp,
    ekko~bedat,
    ekko~ernam,
    ekko~waers,
    ekpo~ebelp,
    ekpo~matnr,
    ekpo~txz01,
    ekpo~menge,
    ekpo~meins,
    ekpo~netpr,
    ekpo~werks

    INTO TABLE @lt_result
    FROM ekko
    INNER JOIN ekpo ON ekko~Ebeln = ekpo~Ebeln
    WHERE ekko~lifnr = @iv_doc
    AND EKKO~BSART = 'AN'.

  ev_VEN_po = lt_result.




ENDFUNCTION.

FUNCTION ZFM_VEN_REQFORQUOT_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_USERNAME) TYPE  LIFNR
*"  EXPORTING
*"     VALUE(EV_VEN_RFQ) TYPE  ZTT_VEN_REQFORQUO_YM
*"----------------------------------------------------------------------


DATA: lt_result TYPE ZTT_VEN_REQFORQUO_YM.


  SELECT
ekko~ebeln,
    ekpo~ebelp,
    ekko~bedat,
    ekko~ekorg,
    ekko~ekgrp,
    ekpo~matnr,
    ekpo~menge,
    ekpo~txz01,
    ekpo~netpr,
    ekko~waers,
    ekko~zterm,
    ekpo~meins,
    ekko~bsart
    INTO TABLE @lt_result
    FROM ekko
    INNER JOIN ekpo ON ekko~Ebeln = ekpo~Ebeln
    WHERE ekko~lifnr = @iv_username
    AND EKKO~BSART = 'AN'.

  EV_VEN_RFQ = lt_result.



ENDFUNCTION.

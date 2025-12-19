FUNCTION ZFM_VEN_INVDISPLAY_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_USERNAME) TYPE  LIFNR
*"  EXPORTING
*"     VALUE(EV_VEN_INV) TYPE  ZTT_VEN_INVDISPLAY_YM
*"----------------------------------------------------------------------
DATA: lt_RESULT TYPE ZTT_VEN_INVDISPLAY_YM.

  SELECT a~belnr,
         a~bldat,
         b~matnr,
         a~waers
    INTO TABLE @lt_result
    FROM rbkp AS a
    INNER JOIN rseg AS b
      ON a~belnr = b~belnr
      AND a~gjahr = b~gjahr
    WHERE a~lifnr = @iv_username
    AND a~blart = 'RE'.

  ev_ven_INV = lt_RESULT.




ENDFUNCTION.

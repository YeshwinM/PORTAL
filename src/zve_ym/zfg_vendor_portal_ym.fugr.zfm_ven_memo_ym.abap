FUNCTION ZFM_VEN_MEMO_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_USERNAME) TYPE  LIFNR
*"  EXPORTING
*"     VALUE(EV_VEN) TYPE  ZTT_VEN_MEMO_YM
*"----------------------------------------------------------------------
DATA: ls_memo TYPE ZTT_VEN_MEMO_YM.
  SELECT
    bkpf~budat,
    bkpf~bldat,
    bkpf~waers,
    bkpf~usnam,
    bseg~bukrs,
    bseg~shkzg,
    bseg~wrbtr,
    bseg~belnr,
    bseg~gjahr,
    bseg~buzei,
    bseg~hkont,
    bseg~bschl,
    bseg~lifnr,
    bseg~augbl
    INTO TABLE @ls_memo
    FROM bkpf
    INNER JOIN bseg ON bkpf~belnr = bseg~belnr
    WHERE bseg~lifnr = @iv_username
    AND bseg~SHKZG IN ('S', 'H').
  ev_ven = ls_memo.




ENDFUNCTION.

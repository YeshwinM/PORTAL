FUNCTION ZFM_VEN_PROFILE_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_USERNAME) TYPE  LIFNR
*"  EXPORTING
*"     VALUE(EV_PROFILE) TYPE  ZST_VEN_PROFILE_YM
*"----------------------------------------------------------------------
DATA: ls_LFA1 TYPE LFA1.

  SELECT SINGLE * INTO ls_LFA1
    FROM LFA1
    WHERE LIFNR = iv_USERNAME.

  IF sy-subrc = 0.
    ev_profile-name1     = ls_lfa1-name1.
    ev_profile-lifnr     = ls_lfa1-lifnr.
    ev_profile-land1     = ls_lfa1-land1.
    ev_profile-ort01 = ls_lfa1-ort01.
  ELSE.
    CLEAR ev_profile.
  ENDIF.




ENDFUNCTION.

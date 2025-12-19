FUNCTION ZFM_CUS_PROFILE_YM.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CUSTOMER_ID) TYPE  KUNNR
*"  EXPORTING
*"     VALUE(PROFILE) TYPE  ZST_CUS_PROFILE_YM
*"----------------------------------------------------------------------
DATA: lv_adrnr TYPE adrnr.
  CLEAR PROFILE.
  SELECT SINGLE kunnr name1 ort01 pstlz stras adrnr land1 regio
    INTO (PROFILE-customer_id,
          PROFILE-name1,
          PROFILE-city,
          PROFILE-postal_code,
          PROFILE-street,
          PROFILE-address,
          PROFILE-country,
          PROFILE-region)
    FROM kna1
    WHERE kunnr = CUSTOMER_ID.
  IF sy-subrc <> 0.
    WRITE: / 'Customer not found'.
    RETURN.
  ENDIF.
  lv_adrnr = PROFILE-address.
  IF lv_adrnr IS INITIAL.
    WRITE: / 'Address number missing in KNA1'.
    RETURN.
  ENDIF.
  SELECT SINGLE smtp_addr persnumber
    INTO (PROFILE-e_mail, PROFILE-person_no)
    FROM adr6
    WHERE addrnumber = lv_adrnr.
  IF sy-subrc <> 0.
    WRITE: / 'Email/Person No not maintained in ADR6'.
  ENDIF.

ENDFUNCTION.

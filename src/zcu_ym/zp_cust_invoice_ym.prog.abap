*&---------------------------------------------------------------------*
*& Report ZP_CUST_INVOICE_YM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZP_CUST_INVOICE_YM.




TYPE-POOLS : sfp.


DATA: wa_data TYPE zcustpl_invoicepdf_s.

DATA: it_item TYPE zcustpl_invoicepdftt_t.

*DATA:

*  ls_outputparams TYPE sfpoutputparams,

*  lv_fm_name      TYPE rs38l_fnam,

*  ls_pdf_file     TYPE fpformoutput.

*DATA: ls_ctrl_params TYPE ssfctrlop,     " <-- correct structure for control

*      ls_output_opts TYPE ssfcompop.

*DATA: lv_logo TYPE xstring,

*

*      lv_sign TYPE xstring.

*

*CONSTANTS : lv_header_logo TYPE tdobname VALUE 'ZVENDP_LOGO',

*

*            lv_SIGN_IMG    TYPE tdobname VALUE 'ZVENDP_SIGN',

           CONSTANTS : c_ID           TYPE tdidgr VALUE 'BMAP',

            c_BTYPE        TYPE tdbtype VALUE 'BCOL',

            c_OBJECT       TYPE tdobjectgr VALUE 'GRAPHICS'.

PARAMETERS: p_invo TYPE vbeln_VF.

SELECT SINGLE

       kunag      AS customer_id,

       vbeln      AS invoice_no,

       fkdat      AS invoice_date,

       vkorg      AS sales_org,

       fkart      AS billing_type

  INTO @wa_data

  FROM vbrk

  WHERE vbeln = @p_invo.

IF sy-subrc <> 0.

  MESSAGE 'Invoice not found' TYPE 'E'.

  EXIT.

ENDIF.

" Get item data from VBRP

SELECT a~matnr       AS material_no,

       a~arktx       AS material_desc,

       a~fkimg       AS quantity,

       a~netwr       AS net_item,

       a~waerk       AS currency,

       a~vrkme       AS unit,

       b~vkorg       AS sales_org,

       b~fkart       AS billing_type,

       b~vbeln       AS invoice_no

  INTO CORRESPONDING FIELDS OF TABLE @it_item

  FROM vbrp AS a

  INNER JOIN vbrk AS b

    ON a~vbeln = b~vbeln

  WHERE a~vbeln = @p_invo.


IF sy-subrc <> 0.

  MESSAGE 'Invoice not found' TYPE 'E'.

  EXIT.

ENDIF.

" Get item data from VBRP

DATA: lv_func     TYPE funcname VALUE 'ZDT_CUSTINVOICEPDFSFORM',

      lv_out      TYPE sfpoutputparams,

      lv_doc      TYPE sfpdocparams,

      lv_form     TYPE fpformoutput,

      lv_filename TYPE string,

      lv_path     TYPE string,

      lv_fullpath TYPE string.

*LS_DOCPARAMS-LANGU  = SY-LANGU.

lv_out-nodialog = abap_true.

lv_out-preview  = abap_true.

lv_out-getpdf = abap_true.

lv_out-dest     = 'LP01'.

lv_doc-dynamic = abap_true.

lv_doc-langu      = sy-langu.


*CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp

*  EXPORTING

*    p_object       = c_OBJECT

*    p_name         = lv_header_logo

*    p_id           = c_ID

*    p_btype        = c_BTYPE

*  RECEIVING

*    p_bmp          = lv_logo

*  EXCEPTIONS

*    not_found      = 1

*    internal_error = 2

*    OTHERS         = 3.

*

*CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp

*  EXPORTING

*    p_object       = c_OBJECT

*    p_name         = lv_SIGN_IMG

*    p_id           = c_ID

*    p_btype        = c_BTYPE

*  RECEIVING

*    p_bmp          = lv_sign

*  EXCEPTIONS

*    not_found      = 1

*    internal_error = 2

*    OTHERS         = 3.


CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'

  EXPORTING

    i_name     = lv_func

  IMPORTING

    e_funcname = lv_func.

CALL FUNCTION 'FP_JOB_OPEN'

  CHANGING

    ie_outputparams = lv_out

  EXCEPTIONS

    cancel          = 1

    usage_error     = 2

    system_error    = 3

    internal_error  = 4

    OTHERS          = 5.

IF sy-subrc <> 0.

* Implement suitable error handling here

ENDIF.

CALL FUNCTION lv_func

  EXPORTING

   /1BCDWB/DOCPARAMS        = lv_doc

    it_header                = wa_data

    it_item                  = it_item

 IMPORTING

   /1BCDWB/FORMOUTPUT       = lv_form

 EXCEPTIONS

   USAGE_ERROR              = 1

   SYSTEM_ERROR             = 2

   INTERNAL_ERROR           = 3

   OTHERS                   = 4

          .

IF sy-subrc <> 0.

* Implement suitable error handling here

ENDIF.



CALL FUNCTION 'FP_JOB_CLOSE'

  EXCEPTIONS

    usage_error    = 1

    system_error   = 2

    internal_error = 3

    OTHERS         = 4.

IF sy-subrc <> 0.

* Implement suitable error handling here

ENDIF.


IF lv_form-pdf IS NOT INITIAL.


  EXPORT lv_form TO MEMORY ID 'C_MEMORY'.


  DATA: it_pdf TYPE STANDARD TABLE OF x255,


        lv_len TYPE i.


  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'

    EXPORTING

      buffer        = lv_form-pdf

    IMPORTING

      output_length = lv_len

    TABLES

      binary_tab    = it_pdf.


  CALL METHOD cl_gui_frontend_services=>file_save_dialog

    EXPORTING

      default_extension = 'pdf'

      default_file_name = |Invoice_{ p_invo }.pdf|

      file_filter       = 'PDF Files (*.pdf)|*.pdf|'

    CHANGING

      filename          = lv_filename

      path              = lv_path

      fullpath          = lv_fullpath

    EXCEPTIONS

      OTHERS            = 1.


  IF sy-subrc <> 0.


    MESSAGE 'Download cancelled by user' TYPE 'I'.


    RETURN.


  ENDIF.


  CALL FUNCTION 'GUI_DOWNLOAD'

    EXPORTING

      filename = lv_fullpath

      filetype = 'BIN'

    TABLES

      data_tab = it_pdf.


  MESSAGE |PDF saved to { lv_fullpath }| TYPE 'S'.

ENDIF.

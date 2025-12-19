CLASS zsfp_portal_ym DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_amdp_marker_hdb.
 TYPES: tt_planned_orders TYPE ZTT_PLANORDER_SFP_YM,
           tt_prod_orders    TYPE ZTT_PRODORDER_SFP_YM.

    " Method 1: Get Planned Orders
    CLASS-METHODS get_planned_orders
      IMPORTING VALUE(iv_client) TYPE mandt
      EXPORTING VALUE(et_orders) TYPE tt_planned_orders.

    " Method 2: Get Production Orders
    CLASS-METHODS get_prod_orders
      IMPORTING VALUE(iv_client) TYPE mandt
      EXPORTING VALUE(et_orders) TYPE tt_prod_orders.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zsfp_portal_ym IMPLEMENTATION.
METHOD get_planned_orders BY DATABASE PROCEDURE FOR HDB
                            LANGUAGE SQLSCRIPT
                            OPTIONS READ-ONLY
                            USING plaf.

    et_orders = SELECT
                  plnum,
                  matnr as plmat,
                  plwrk,
                  beskz,
                  gsmng,
                  tlmng,
                  avmng,
                  bdmng,
                  psttr,
                  pertr,
                  pedtr,
                  webaz,
                  dispo,
                  umskz,
                  meins
                FROM plaf
                WHERE mandt = :iv_client;

  ENDMETHOD.



  METHOD get_prod_orders BY DATABASE PROCEDURE FOR HDB
                         LANGUAGE SQLSCRIPT
                         OPTIONS READ-ONLY
                         USING aufk afko afpo.

    et_orders = SELECT
                  a.aufnr,
                  a.auart,
                  a.werks,
                  a.ktext,
                  a.aenam,
                  a.objnr,
                  b.gstrp,
                  b.gltrp,
                  b.gamng,
                  b.gmein,
                  b.ftrmi,
                  b.ftrmp,
                  c.matnr
                FROM aufk AS a
                INNER JOIN afko AS b
                  ON a.mandt = b.mandt
                 AND a.aufnr = b.aufnr
                LEFT OUTER JOIN afpo AS c
                  ON a.mandt = c.mandt
                 AND a.aufnr = c.aufnr
                WHERE a.mandt = :iv_client;

  ENDMETHOD.
ENDCLASS.

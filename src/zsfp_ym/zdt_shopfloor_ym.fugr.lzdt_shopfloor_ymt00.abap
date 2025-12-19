*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDT_SHOPFLOOR_YM................................*
DATA:  BEGIN OF STATUS_ZDT_SHOPFLOOR_YM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDT_SHOPFLOOR_YM              .
CONTROLS: TCTRL_ZDT_SHOPFLOOR_YM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDT_SHOPFLOOR_YM              .
TABLES: ZDT_SHOPFLOOR_YM               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

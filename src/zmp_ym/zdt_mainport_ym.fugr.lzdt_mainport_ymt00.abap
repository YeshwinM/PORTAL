*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDT_MAINPORT_YM.................................*
DATA:  BEGIN OF STATUS_ZDT_MAINPORT_YM               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDT_MAINPORT_YM               .
CONTROLS: TCTRL_ZDT_MAINPORT_YM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDT_MAINPORT_YM               .
TABLES: ZDT_MAINPORT_YM                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

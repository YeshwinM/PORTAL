CLASS zehsm_portal_yma DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_amdp_marker_hdb.



    CLASS-METHODS get_profile
      IMPORTING
        VALUE(iv_client)     TYPE mandt
        VALUE(iv_employeeid) TYPE pernr_d
      EXPORTING
        VALUE(et_profile)    TYPE ZTT_PROFILE_EHSM_YM.


    CLASS-METHODS get_incidents
      IMPORTING
        VALUE(iv_client)     TYPE mandt
        VALUE(iv_employeeid) TYPE persno
      EXPORTING
        VALUE(et_incidents)  TYPE ZTT_INCIDENT_EHSM_YM.


    CLASS-METHODS get_risks
      IMPORTING
        VALUE(iv_client)     TYPE mandt
        VALUE(iv_employeeid) TYPE persno
      EXPORTING
        VALUE(et_risks)      TYPE ZTT_RISK_EHSM_YM.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zehsm_portal_yma IMPLEMENTATION.
* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zehsm_portal_yma=>GET_PROFILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLIENT                      TYPE        MANDT
* | [--->] IV_EMPLOYEEID                  TYPE        PERNR_D
* | [<---] ET_PROFILE                     TYPE        ZTT_PROFILE_EHSM_YM
* +--------------------------------------------------------------------------------------</SIGNATURE>
 METHOD get_profile BY DATABASE PROCEDURE
                      FOR HDB
                      LANGUAGE SQLSCRIPT
                      OPTIONS READ-ONLY
                      USING pa0002 pa0001 pa0006 pa0105 pa0000.

    et_profile =
      SELECT
        a.pernr        AS employee_id,
        c.werks        AS plant,
        a.vorna        AS first_name,
        a.nachn        AS last_name,
        a.gesch        AS gender,
        d.usrid_long   AS email_id,
        a.sprsl        AS comm_language,
        a.natio        AS nationality,
        b.ort01        AS city,
        b.stras        AS street,
        b.land1        AS country,
        b.pstlz        AS postal_code,
        c.bukrs        AS company,
        e.stat2        AS employee_status,
        a.titel        AS title,
        c.begda        AS start_date
      FROM pa0002 AS a
      INNER JOIN pa0006 AS b
        ON  a.mandt = b.mandt
        AND a.pernr = b.pernr
      INNER JOIN pa0001 AS c
        ON  a.mandt = c.mandt
        AND a.pernr = c.pernr
      LEFT OUTER JOIN pa0105 AS d
        ON  a.mandt = d.mandt
        AND a.pernr = d.pernr
        AND d.subty = '0010'
      LEFT OUTER JOIN pa0000 AS e
        ON  a.mandt = e.mandt
        AND a.pernr = e.pernr
      WHERE a.mandt = :iv_client
        AND a.pernr = :iv_employeeid
        AND b.subty = '1'
        AND c.endda >= CURRENT_DATE
        AND c.begda <= CURRENT_DATE
        AND b.endda >= CURRENT_DATE
        AND b.begda <= CURRENT_DATE;

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zehsm_portal_yma=>GET_INCIDENTS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLIENT                      TYPE        MANDT
* | [--->] IV_EMPLOYEEID                  TYPE        PERSNO
* | [<---] ET_INCIDENTS                   TYPE        ZTT_INCIDENT_EHSM_YM
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_incidents BY DATABASE PROCEDURE
                        FOR HDB
                        LANGUAGE SQLSCRIPT
                        OPTIONS READ-ONLY
                        USING zinci_ehsm_dp pa0001.

    et_incidents =
      SELECT
        p.pernr             AS employee_id,           -- EMPLOYEE_ID
        i.incident_id       AS incident_id,           -- INCIDENT_ID
        i.plant             AS plant,                 -- PLANT
        i.incident_description AS incident_description, -- INCIDENT_DESCRIPTION
        i.incident_category AS incident_category,     -- INCIDENT_CATEGORY
        i.incident_priority AS incident_priority,     -- INCIDENT_PRIORITY
        i.incident_status   AS incident_status,       -- INCIDENT_STATUS
        i.incident_date     AS incident_date,         -- INCIDENT_DATE
        i.incident_time     AS incident_time,         -- INCIDENT_TIME
        i.created_by        AS created_by,            -- CREATED_BY
        i.completion_date   AS completion_date,       -- COMPLETION_DATE
        i.completion_time   AS completion_time        -- COMPLETION_TIME
      FROM zinci_ehsm_dp AS i
      INNER JOIN pa0001  AS p
        ON  p.werks = i.plant
      WHERE p.mandt  = :iv_client
        AND p.pernr  = :iv_employeeid
        AND p.endda >= CURRENT_DATE
        AND p.begda <= CURRENT_DATE;

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method zehsm_portal_yma=>GET_RISKS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLIENT                      TYPE        MANDT
* | [--->] IV_EMPLOYEEID                  TYPE        PERSNO
* | [<---] ET_RISKS                       TYPE        ZTT_RISK_EHSM_YM
* +--------------------------------------------------------------------------------------</SIGNATURE>
   METHOD get_risks BY DATABASE PROCEDURE
                    FOR HDB
                    LANGUAGE SQLSCRIPT
                    OPTIONS READ-ONLY
                    USING zrisk_ehsm_dp pa0001.

    et_risks =
      SELECT
        p.pernr                    AS employee_id,                -- EMPLOYEE_ID
        r.risk_id                  AS risk_id,                    -- RISK_ID
        r.plant                    AS plant,                      -- PLANT
        r.risk_description         AS risk_description,           -- RISK_DESCRIPTION
        r.risk_category            AS risk_category,              -- RISK_CATEGORY
        r.risk_severity            AS risk_severity,              -- RISK_SEVERITY
        r.mitigation_measures      AS mitigation_measures,        -- MITIGATION_MEASURES
        r.likelihood               AS likelihood,                 -- LIKELIHOOD
        r.created_by               AS created_by,                 -- CREATED_BY
        r.risk_identification_date AS risk_identification_date    -- RISK_IDENTIFICATION_DATE
      FROM zrisk_ehsm_dp AS r
      INNER JOIN pa0001  AS p
        ON  p.werks = r.plant
      WHERE p.mandt  = :iv_client
        AND p.pernr  = :iv_employeeid
        AND p.endda >= CURRENT_DATE
        AND p.begda <= CURRENT_DATE;

  ENDMETHOD.
ENDCLASS.

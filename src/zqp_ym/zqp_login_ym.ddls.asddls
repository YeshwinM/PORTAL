@AbapCatalog.sqlViewName: 'ZQPLOGINYMV'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LOGIN DATA DEFINITION'
@Metadata.ignorePropagatedAnnotations: true
@OData.publish: true
define view ZQP_LOGIN_YM as select from zdt_quaport_ym
{
    key username ,
    password,
    cast( 'Success' as abap.char(10) ) as login_status
}

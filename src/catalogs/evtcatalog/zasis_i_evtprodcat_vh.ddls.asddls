@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ASIS - Event Producer Catalog VH (Active)'
define view entity ZASIS_I_EVTPRODCAT_VH
  as select from ZASIS_I_EVTPRODCATALOG
{
  key ClassName,
      Description
}
where
  Status = '1'

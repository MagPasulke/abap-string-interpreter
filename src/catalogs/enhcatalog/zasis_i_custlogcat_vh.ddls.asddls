@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ASIS - Custom Logic Catalog VH (Active)'
define view entity ZASIS_I_CUSTLOGCAT_VH
  as select from ZASIS_I_CUSTLOGCATALOG
{
  key ClassName,
      Description
}
where
  Status = '1'

@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Custom Logic Catalog (Consumption)'
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZASIS_C_CUSTLOGCATALOG
  provider contract transactional_query
  as projection on ZASIS_I_CUSTLOGCATALOG
{
      @Search.defaultSearchElement: true
  key ClassName,
      @Search.defaultSearchElement: true
      Description,
      Status,
      _StatusText : redirected to ZASIS_I_ENHCATSTATTEXT,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}

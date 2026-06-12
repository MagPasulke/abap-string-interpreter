@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Custom Logic Catalog'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZASIS_I_CUSTLOGCATALOG
  as select from zasis_custlogcat
{
  key class_name            as ClassName,
      description           as Description,
      cast( status as ZASIS_ENHCAT_STATUS preserving type ) as Status,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}

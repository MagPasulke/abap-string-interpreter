@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Event Producer Catalog'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZASIS_I_EVTPRODCATALOG
  as select from zasis_evtprodcat
{
  key class_name            as ClassName,
      description           as Description,
      status                as Status,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}

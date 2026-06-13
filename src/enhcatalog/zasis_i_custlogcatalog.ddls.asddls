@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Custom Logic Catalog'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZASIS_I_CUSTLOGCATALOG
  as select from zasis_custlogcat
  association [0..*] to ZASIS_I_ENHCATSTATTEXT as _StatusText on $projection.Status = _StatusText.value_low
{
  key class_name            as ClassName,
      description           as Description,
      @ObjectModel.text.association: '_StatusText'
      status                as Status,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _StatusText
}

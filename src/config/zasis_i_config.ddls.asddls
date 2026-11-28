@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Configuration'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZASIS_I_CONFIG
  as select from zasis_config
{
  key config_key            as ConfigKey,
      config_value          as ConfigValue,
      description           as Description,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}

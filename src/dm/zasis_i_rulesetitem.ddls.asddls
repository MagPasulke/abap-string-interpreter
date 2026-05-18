@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Ruleset Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZASIS_I_RULESETITEM
  as select from zasis_rulesetitm
  association to parent ZASIS_I_RULESET as _Header on $projection.RuleSetUUID = _Header.RuleSetUUID
{
  key rulesetuuid           as RuleSetUUID,
  key interpretationitm     as InterpretationItem,
      intpretationtarget    as IntpretationTarget,
      interpretationrule    as InterpretationRule,
      interpretation_type   as InterpretationType,
      offset_pre            as OffsetPre,
      offset_post           as OffsetPost,
      replacement_string    as ReplacementString,
      custom_logic          as CustomLogic,
      event_producer        as EventProducer,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Header
}

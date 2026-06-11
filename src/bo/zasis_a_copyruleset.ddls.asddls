@EndUserText.label: 'ASIS - Copy RuleSet Input Parameter'
define abstract entity ZASIS_A_COPYRULESET
{
  new_ruleset_id      : zasis_ruleset_id;
  copy_event_producer : abap_boolean;
  copy_custom_logic   : abap_boolean;
}

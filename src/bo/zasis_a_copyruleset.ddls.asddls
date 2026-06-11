@EndUserText.label: 'ASIS - Copy RuleSet Input Parameter'
define abstract entity ZASIS_A_COPYRULESET
{
  @EndUserText.label: 'New RuleSet ID'
  new_ruleset_id      : zasis_ruleset_id;
  @EndUserText.label: 'Copy Event Producer'
  copy_event_producer : abap_boolean;
  @EndUserText.label: 'Copy Custom Logic'
  copy_custom_logic   : abap_boolean;
}

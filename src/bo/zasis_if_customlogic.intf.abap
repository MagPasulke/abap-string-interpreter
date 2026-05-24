INTERFACE zasis_if_customlogic
  PUBLIC.

  "! Executes custom interpretation logic for a single RuleSet item and returns the result string.
  "! @parameter string_to_be_interpretet | Input string to interpret (note: intentional typo in parameter name)
  "! @parameter ruleset                  | Reference to the full RuleSet, providing context for all rules
  "! @parameter current_rule_item        | The specific rule item currently being processed
  "! @parameter context                  | Optional key-value context data passed through from the caller
  "! @parameter interpretation_result    | The interpreted result string; return initial if no match applies
  "! @raising   zasis_cx_exc | Raised when the custom logic encounters an unrecoverable error
  METHODS execute
    IMPORTING
      string_to_be_interpretet     TYPE string
      ruleset                      TYPE REF TO zasis_if_ruleset
      current_rule_item            TYPE zasis_rulesetitm
      context                      TYPE zasis_tt_interpret_context OPTIONAL
    RETURNING
      VALUE(interpretation_result) TYPE string
    RAISING
      zasis_cx_exc.

ENDINTERFACE.

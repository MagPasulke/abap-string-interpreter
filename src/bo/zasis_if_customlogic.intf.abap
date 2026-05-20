INTERFACE zasis_if_customlogic
  PUBLIC.

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

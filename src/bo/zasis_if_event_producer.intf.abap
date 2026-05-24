INTERFACE zasis_if_event_producer
  PUBLIC .

  "! Called after a single RuleSet item has been interpreted successfully. Implement side effects here.
  "! @parameter ruleset               | Reference to the full RuleSet that was used for interpretation
  "! @parameter interpretation_itm    | The rule item number that produced the result
  "! @parameter interpretation_result | The result line containing target field and matched value
  "! @parameter context               | Optional key-value context data passed through from the caller
  "! @raising   zasis_cx_exc | Raised when the event producer encounters an unrecoverable error
  METHODS on_item_interpreted
    IMPORTING
      ruleset               TYPE REF TO zasis_if_ruleset
      interpretation_itm    TYPE zasis_ruleset_item
      interpretation_result TYPE zasis_interpret_result_line
      context               TYPE zasis_tt_interpret_context OPTIONAL
    RAISING
      zasis_cx_exc.

ENDINTERFACE.

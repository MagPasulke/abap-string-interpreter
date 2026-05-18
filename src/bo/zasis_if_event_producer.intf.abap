INTERFACE zasis_if_event_producer
  PUBLIC .

  METHODS on_item_interpreted
    IMPORTING
      ruleset               TYPE REF TO zasis_if_ruleset
      interpretation_itm    TYPE zasis_ruleset_item
      interpretation_result TYPE zasis_interpret_result_line.

ENDINTERFACE.

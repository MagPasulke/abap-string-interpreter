INTERFACE zasis_if_interpreter
  PUBLIC .

  METHODS execute IMPORTING string_to_be_interpreted     TYPE string
                            ruleset                      TYPE REF TO zasis_if_ruleset
                            context                      TYPE zasis_tt_interpret_context OPTIONAL
                  RETURNING VALUE(interpretation_result) TYPE zasis_tt_interpretationresult
                  RAISING   zasis_cx_exc
                            zasis_cx_no_auth.

ENDINTERFACE.

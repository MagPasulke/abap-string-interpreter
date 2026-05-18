interface ZASIS_IF_INTERPRETER
  public .

  METHODS execute IMPORTING string_to_be_interpreted     TYPE string
                            ruleset                      TYPE REF TO zasis_if_ruleset
                  RETURNING VALUE(interpretation_result) TYPE zasis_tt_interpretationresult
                  RAISING   zasis_cx_exc
                            zasis_cx_no_auth.

endinterface.

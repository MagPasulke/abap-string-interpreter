INTERFACE zasis_if_interpreter
  PUBLIC .

  "! Interprets a string against all rule items of a RuleSet and returns the output wrapper
  "! containing one result line per rule item plus the context that was active during interpretation.
  "! @parameter string_to_be_interpreted | Input string to interpret (e.g. a barcode or scanned value)
  "! @parameter ruleset                  | The RuleSet defining the ordered list of MATCH and REPLACE rules
  "! @parameter context                  | Optional key-value context data forwarded to custom logic and event producers
  "! @parameter output                   | Wrapper containing results (one line per rule item) and context
  "! @raising   zasis_cx_exc     | Raised when the input string is empty or a rule item has an unknown type
  "! @raising   zasis_cx_no_auth | Raised when the user lacks execute authorization for the RuleSet
  METHODS execute IMPORTING string_to_be_interpreted TYPE string
                            ruleset                  TYPE REF TO zasis_if_ruleset
                            context                  TYPE zasis_tt_interpret_context OPTIONAL
                  RETURNING VALUE(output)            TYPE zasis_interpret_output
                  RAISING   zasis_cx_exc
                            zasis_cx_no_auth.

ENDINTERFACE.

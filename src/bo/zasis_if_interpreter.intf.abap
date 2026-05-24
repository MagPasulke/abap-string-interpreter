INTERFACE zasis_if_interpreter
  PUBLIC .

  "! Interprets a string against all rule items of a RuleSet and returns one result line per rule item.
  "! @parameter string_to_be_interpreted | Input string to interpret (e.g. a barcode or scanned value)
  "! @parameter ruleset                  | The RuleSet defining the ordered list of MATCH and REPLACE rules
  "! @parameter context                  | Optional key-value context data forwarded to custom logic and event producers
  "! @parameter interpretation_result    | One result line per rule item; unmatched items carry 'no match' as value
  "! @raising   zasis_cx_exc     | Raised when the input string is empty or a rule item has an unknown type
  "! @raising   zasis_cx_no_auth | Raised when the user lacks execute authorization for the RuleSet
  METHODS execute IMPORTING string_to_be_interpreted     TYPE string
                            ruleset                      TYPE REF TO zasis_if_ruleset
                            context                      TYPE zasis_tt_interpret_context OPTIONAL
                  RETURNING VALUE(interpretation_result) TYPE zasis_tt_interpretationresult
                  RAISING   zasis_cx_exc
                            zasis_cx_no_auth.

ENDINTERFACE.

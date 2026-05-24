INTERFACE zasis_if_auth_checker
  PUBLIC.

  "! Checks whether the current user is authorized to read the given RuleSet.
  "! @parameter ruleset_id | ID of the RuleSet to check read authorization for
  "! @raising   zasis_cx_no_auth | Raised when the user lacks read authorization
  METHODS check_read IMPORTING ruleset_id TYPE zasis_ruleset_id
                     RAISING   zasis_cx_no_auth.

  "! Checks whether the current user is authorized to execute the given RuleSet.
  "! @parameter ruleset_id | ID of the RuleSet to check execute authorization for
  "! @raising   zasis_cx_no_auth | Raised when the user lacks execute authorization
  METHODS check_execute IMPORTING ruleset_id TYPE zasis_ruleset_id
                        RAISING   zasis_cx_no_auth.

  "! Checks whether the current user is authorized to create a RuleSet with the given ID.
  "! @parameter ruleset_id | ID of the RuleSet to check create authorization for
  "! @raising   zasis_cx_no_auth | Raised when the user lacks create authorization
  METHODS check_create IMPORTING ruleset_id TYPE zasis_ruleset_id
                        RAISING   zasis_cx_no_auth.

  "! Checks whether the current user is authorized to change the given RuleSet.
  "! @parameter ruleset_id | ID of the RuleSet to check change authorization for
  "! @raising   zasis_cx_no_auth | Raised when the user lacks change authorization
  METHODS check_change IMPORTING ruleset_id TYPE zasis_ruleset_id
                        RAISING   zasis_cx_no_auth.

ENDINTERFACE.

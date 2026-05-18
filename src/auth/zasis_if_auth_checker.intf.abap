INTERFACE zasis_if_auth_checker
  PUBLIC.

  METHODS check_read IMPORTING ruleset_id TYPE zasis_ruleset_id
                     RAISING   zasis_cx_no_auth.

  METHODS check_execute IMPORTING ruleset_id TYPE zasis_ruleset_id
                        RAISING   zasis_cx_no_auth.

  METHODS check_create IMPORTING ruleset_id TYPE zasis_ruleset_id
                        RAISING   zasis_cx_no_auth.

  METHODS check_change IMPORTING ruleset_id TYPE zasis_ruleset_id
                        RAISING   zasis_cx_no_auth.

ENDINTERFACE.

INTERFACE zasis_if_auth_checker
  PUBLIC.

  "! <p class="shortText">Checks read authorization for the given RuleSet.</p>
  METHODS check_read IMPORTING ruleset_id TYPE zasis_ruleset_id
                     RAISING   zasis_cx_no_auth.

  "! <p class="shortText">Checks execute authorization for the given RuleSet.</p>
  METHODS check_execute IMPORTING ruleset_id TYPE zasis_ruleset_id
                        RAISING   zasis_cx_no_auth.

  "! <p class="shortText">Checks create authorization for the given RuleSet.</p>
  METHODS check_create IMPORTING ruleset_id TYPE zasis_ruleset_id
                        RAISING   zasis_cx_no_auth.

  "! <p class="shortText">Checks change authorization for the given RuleSet.</p>
  METHODS check_change IMPORTING ruleset_id TYPE zasis_ruleset_id
                        RAISING   zasis_cx_no_auth.

ENDINTERFACE.

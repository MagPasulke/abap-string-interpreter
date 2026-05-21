CLASS zasis_cl_ruleset_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-DATA ruleset_refs TYPE zasis_tt_rulesetrefs READ-ONLY.

    CLASS-METHODS get_ruleset_by_rulesetid IMPORTING ruleset_id       TYPE zasis_ruleset_id
                                                      auth_checker     TYPE REF TO zasis_if_auth_checker OPTIONAL
                              RETURNING VALUE(ruleset_ref) TYPE REF TO zasis_if_ruleset
                              RAISING   zasis_cx_exc
                                        zasis_cx_no_auth.

    CLASS-METHODS invalidate IMPORTING ruleset_id TYPE zasis_ruleset_id.
    CLASS-METHODS clear_cache.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_ruleset_factory IMPLEMENTATION.


  METHOD get_ruleset_by_rulesetid.

    DATA rulesetitems TYPE zasis_tt_rulesetitm.

    DATA(checker) = COND #( WHEN auth_checker IS BOUND
                            THEN auth_checker
                            ELSE NEW zasis_cl_auth_checker( ) ).

    "check auth first
    checker->check_read( ruleset_id = ruleset_id ).

    "check the buffer first if ruleset was already read
    READ TABLE ruleset_refs WITH KEY ruleset_id = ruleset_id BINARY SEARCH INTO DATA(ruleset).
    IF sy-subrc = 0.
      ruleset_ref = ruleset-ruleset_ref.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM zasis_rulesethd
      WHERE rulesetid = @ruleset_id
      INTO @DATA(rulesetheader).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zasis_cx_exc(
        textid   = zasis_cx_exc=>unknown_ruleset
        ruleset  = ruleset_id
      ).
    ENDIF.

    SELECT * FROM zasis_rulesetitm "#EC SELECT_PERFORMANCE
      WHERE rulesetuuid = @rulesetheader-rulesetuuid
      ORDER BY interpretationitm
      INTO CORRESPONDING FIELDS OF TABLE @rulesetitems.

    IF sy-subrc <> 0.

      RAISE EXCEPTION NEW zasis_cx_exc(
        textid   = zasis_cx_exc=>unknown_ruleset
        ruleset  = ruleset_id
      ).

    ENDIF.

    ruleset_ref = NEW zasis_cl_ruleset( header = rulesetheader
                                        items  = rulesetitems ).


    INSERT VALUE #( ruleset_id  = ruleset_ref->header-rulesetid
                    ruleset_ref = ruleset_ref  ) INTO TABLE ruleset_refs.

  ENDMETHOD.

  METHOD invalidate.
    DELETE ruleset_refs WHERE ruleset_id = ruleset_id.
  ENDMETHOD.

  METHOD clear_cache.
    CLEAR ruleset_refs.
  ENDMETHOD.
ENDCLASS.

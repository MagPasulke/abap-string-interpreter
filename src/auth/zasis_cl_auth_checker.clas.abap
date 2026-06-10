CLASS zasis_cl_auth_checker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zasis_if_auth_checker .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS check_authority
      IMPORTING
        ruleset_id TYPE zasis_ruleset_id
        activity   TYPE string
      RAISING
        zasis_cx_no_auth.
ENDCLASS.



CLASS zasis_cl_auth_checker IMPLEMENTATION.

  METHOD check_authority.
    ASSERT ruleset_id IS NOT INITIAL.
    AUTHORITY-CHECK OBJECT 'ZASIS_GRL'
                    ID 'ZASIS_RULE' FIELD ruleset_id
                    ID 'ACTVT'      FIELD activity.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zasis_cx_no_auth( ).
    ENDIF.
  ENDMETHOD.

  METHOD zasis_if_auth_checker~check_read.
    check_authority(
      ruleset_id = ruleset_id
      activity   = '03' ).
  ENDMETHOD.

  METHOD zasis_if_auth_checker~check_execute.
    check_authority(
      ruleset_id = ruleset_id
      activity   = '16' ).
  ENDMETHOD.

  METHOD zasis_if_auth_checker~check_create.
    check_authority(
      ruleset_id = ruleset_id
      activity   = '01' ).
  ENDMETHOD.

  METHOD zasis_if_auth_checker~check_change.
    check_authority(
      ruleset_id = ruleset_id
      activity   = '02' ).
  ENDMETHOD.

ENDCLASS.

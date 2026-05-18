CLASS zasis_cl_auth_checker DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zasis_if_auth_checker .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_auth_checker IMPLEMENTATION.


  METHOD zasis_if_auth_checker~check_execute.
      ASSERT ruleset_id IS NOT INITIAL.

    AUTHORITY-CHECK OBJECT 'ZASIS_GRL'
                    ID 'ZASIS_RULE' FIELD ruleset_id
                    ID 'ACTVT' FIELD '16'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zasis_cx_no_auth( ).
    ENDIF.
  ENDMETHOD.

  METHOD zasis_if_auth_checker~check_read.
    ASSERT ruleset_id IS NOT INITIAL.

    AUTHORITY-CHECK OBJECT 'ZASIS_GRL'
                    ID 'ZASIS_RULE' FIELD ruleset_id
                    ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zasis_cx_no_auth( ).
    ENDIF.
  ENDMETHOD.


  METHOD zasis_if_auth_checker~check_change.

      ASSERT ruleset_id IS NOT INITIAL.

    AUTHORITY-CHECK OBJECT 'ZASIS_GRL'
                    ID 'ZASIS_RULE' FIELD ruleset_id
                    ID 'ACTVT' FIELD '02'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zasis_cx_no_auth( ).
    ENDIF.

  ENDMETHOD.

  METHOD zasis_if_auth_checker~check_create.
    ASSERT ruleset_id IS NOT INITIAL.

    AUTHORITY-CHECK OBJECT 'ZASIS_GRL'
                    ID 'ZASIS_RULE' FIELD ruleset_id
                    ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zasis_cx_no_auth( ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

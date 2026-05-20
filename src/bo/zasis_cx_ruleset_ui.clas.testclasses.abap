*"* use this source file for your ABAP unit test classes

CLASS ltcl_message_consistency DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS assert_message_resolves
      IMPORTING textid LIKE if_t100_message=>t100key.

    METHODS test_duplicate_rulesetid FOR TESTING.
    METHODS test_invalid_regex FOR TESTING.
    METHODS test_no_auth FOR TESTING.
    METHODS test_event_producer_not_exist FOR TESTING.
    METHODS test_event_producer_no_intf FOR TESTING.
    METHODS test_custom_logic_not_exist FOR TESTING.
    METHODS test_custom_logic_no_intf FOR TESTING.
ENDCLASS.

CLASS ltcl_message_consistency IMPLEMENTATION.

  METHOD assert_message_resolves.
    MESSAGE ID textid-msgid TYPE 'E' NUMBER textid-msgno INTO DATA(msg_text).

    cl_abap_unit_assert=>assert_not_initial(
      act = msg_text
      msg = |Message { textid-msgid }/{ textid-msgno } could not be resolved| ).
  ENDMETHOD.

  METHOD test_duplicate_rulesetid.
    assert_message_resolves( textid = zasis_cx_ruleset_ui=>duplicate_rulesetid ).
  ENDMETHOD.

  METHOD test_invalid_regex.
    assert_message_resolves( textid = zasis_cx_ruleset_ui=>invalid_regex ).
  ENDMETHOD.

  METHOD test_no_auth.
    assert_message_resolves( textid = zasis_cx_ruleset_ui=>no_auth ).
  ENDMETHOD.

  METHOD test_event_producer_not_exist.
    assert_message_resolves( textid = zasis_cx_ruleset_ui=>event_producer_not_exist ).
  ENDMETHOD.

  METHOD test_event_producer_no_intf.
    assert_message_resolves( textid = zasis_cx_ruleset_ui=>event_producer_no_intf ).
  ENDMETHOD.

  METHOD test_custom_logic_not_exist.
    assert_message_resolves( textid = zasis_cx_ruleset_ui=>custom_logic_not_exist ).
  ENDMETHOD.

  METHOD test_custom_logic_no_intf.
    assert_message_resolves( textid = zasis_cx_ruleset_ui=>custom_logic_no_intf ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_message_consistency IMPLEMENTATION.

  METHOD assert_message_exists.
    SELECT SINGLE @abap_true
      FROM t100
      WHERE sprsl = @sy-langu
        AND arbgb = @msgid
        AND msgnr = @msgno
      INTO @DATA(exists).

    cl_abap_unit_assert=>assert_true(
      act = exists
      msg = |Message { msgid }/{ msgno } not found in T100| ).
  ENDMETHOD.

  METHOD test_duplicate_rulesetid.
    assert_message_exists( msgid = zasis_cx_ruleset_ui=>duplicate_rulesetid-msgid
                           msgno = zasis_cx_ruleset_ui=>duplicate_rulesetid-msgno ).
  ENDMETHOD.

  METHOD test_invalid_regex.
    assert_message_exists( msgid = zasis_cx_ruleset_ui=>invalid_regex-msgid
                           msgno = zasis_cx_ruleset_ui=>invalid_regex-msgno ).
  ENDMETHOD.

  METHOD test_no_auth.
    assert_message_exists( msgid = zasis_cx_ruleset_ui=>no_auth-msgid
                           msgno = zasis_cx_ruleset_ui=>no_auth-msgno ).
  ENDMETHOD.

  METHOD test_event_producer_not_exist.
    assert_message_exists( msgid = zasis_cx_ruleset_ui=>event_producer_not_exist-msgid
                           msgno = zasis_cx_ruleset_ui=>event_producer_not_exist-msgno ).
  ENDMETHOD.

  METHOD test_event_producer_no_intf.
    assert_message_exists( msgid = zasis_cx_ruleset_ui=>event_producer_no_intf-msgid
                           msgno = zasis_cx_ruleset_ui=>event_producer_no_intf-msgno ).
  ENDMETHOD.

  METHOD test_custom_logic_not_exist.
    assert_message_exists( msgid = zasis_cx_ruleset_ui=>custom_logic_not_exist-msgid
                           msgno = zasis_cx_ruleset_ui=>custom_logic_not_exist-msgno ).
  ENDMETHOD.

  METHOD test_custom_logic_no_intf.
    assert_message_exists( msgid = zasis_cx_ruleset_ui=>custom_logic_no_intf-msgid
                           msgno = zasis_cx_ruleset_ui=>custom_logic_no_intf-msgno ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for your ABAP unit test classes

CLASS ltcl_message_consistency DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS assert_message_exists
      IMPORTING msgid TYPE symsgid
                msgno TYPE symsgno.

    METHODS test_class_no_intf FOR TESTING.
    METHODS test_class_not_exist FOR TESTING.
    METHODS test_invalid_api_route FOR TESTING.
    METHODS test_content_not_json FOR TESTING.
    METHODS test_unknown_ruleset FOR TESTING.
    METHODS test_invalid_interpret_type FOR TESTING.
    METHODS test_error_custom_log_proc FOR TESTING.
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

  METHOD test_class_no_intf.
    assert_message_exists( msgid = zasis_cx_exc=>class_no_intf-msgid
                           msgno = zasis_cx_exc=>class_no_intf-msgno ).
  ENDMETHOD.

  METHOD test_class_not_exist.
    assert_message_exists( msgid = zasis_cx_exc=>class_not_exist-msgid
                           msgno = zasis_cx_exc=>class_not_exist-msgno ).
  ENDMETHOD.

  METHOD test_invalid_api_route.
    assert_message_exists( msgid = zasis_cx_exc=>invalid_api_route-msgid
                           msgno = zasis_cx_exc=>invalid_api_route-msgno ).
  ENDMETHOD.

  METHOD test_content_not_json.
    assert_message_exists( msgid = zasis_cx_exc=>content_not_json-msgid
                           msgno = zasis_cx_exc=>content_not_json-msgno ).
  ENDMETHOD.

  METHOD test_unknown_ruleset.
    assert_message_exists( msgid = zasis_cx_exc=>unknown_ruleset-msgid
                           msgno = zasis_cx_exc=>unknown_ruleset-msgno ).
  ENDMETHOD.

  METHOD test_invalid_interpret_type.
    assert_message_exists( msgid = zasis_cx_exc=>invalid_interpretation_type-msgid
                           msgno = zasis_cx_exc=>invalid_interpretation_type-msgno ).
  ENDMETHOD.

  METHOD test_error_custom_log_proc.
    assert_message_exists( msgid = zasis_cx_exc=>error_custom_log_processing-msgid
                           msgno = zasis_cx_exc=>error_custom_log_processing-msgno ).
  ENDMETHOD.

ENDCLASS.

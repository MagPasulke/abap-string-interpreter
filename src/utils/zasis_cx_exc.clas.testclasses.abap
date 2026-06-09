*"* use this source file for your ABAP unit test classes

CLASS ltcl_message_consistency DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS assert_message_resolves
      IMPORTING textid LIKE if_t100_message=>t100key.

    METHODS test_class_no_intf FOR TESTING.
    METHODS test_class_not_exist FOR TESTING.
    METHODS test_invalid_api_route FOR TESTING.
    METHODS test_content_not_json FOR TESTING.
    METHODS test_unknown_ruleset FOR TESTING.
    METHODS test_invalid_interpret_type FOR TESTING.
    METHODS test_error_custom_log_proc FOR TESTING.
    METHODS test_string_to_interpret_empty FOR TESTING.
    METHODS test_method_not_supported FOR TESTING.
    METHODS test_http_request_read_error FOR TESTING.
    METHODS test_http_status_default FOR TESTING.
    METHODS test_http_status_custom FOR TESTING.
ENDCLASS.

CLASS ltcl_message_consistency IMPLEMENTATION.

  METHOD assert_message_resolves.
    MESSAGE ID textid-msgid TYPE 'E' NUMBER textid-msgno INTO DATA(msg_text).

    cl_abap_unit_assert=>assert_not_initial(
      act = msg_text
      msg = |Message { textid-msgid }/{ textid-msgno } could not be resolved| ).
  ENDMETHOD.

  METHOD test_class_no_intf.
    assert_message_resolves( textid = zasis_cx_exc=>class_no_intf ).
  ENDMETHOD.

  METHOD test_class_not_exist.
    assert_message_resolves( textid = zasis_cx_exc=>class_not_exist ).
  ENDMETHOD.

  METHOD test_invalid_api_route.
    assert_message_resolves( textid = zasis_cx_exc=>invalid_api_route ).
  ENDMETHOD.

  METHOD test_content_not_json.
    assert_message_resolves( textid = zasis_cx_exc=>content_not_json ).
  ENDMETHOD.

  METHOD test_unknown_ruleset.
    assert_message_resolves( textid = zasis_cx_exc=>unknown_ruleset ).
  ENDMETHOD.

  METHOD test_invalid_interpret_type.
    assert_message_resolves( textid = zasis_cx_exc=>invalid_interpretation_type ).
  ENDMETHOD.

  METHOD test_error_custom_log_proc.
    assert_message_resolves( textid = zasis_cx_exc=>error_custom_log_processing ).
  ENDMETHOD.

  METHOD test_string_to_interpret_empty.
    assert_message_resolves( textid = zasis_cx_exc=>string_to_interpret_empty ).
  ENDMETHOD.

  METHOD test_method_not_supported.
    assert_message_resolves( textid = zasis_cx_exc=>method_not_supported ).
  ENDMETHOD.

  METHOD test_http_request_read_error.
    assert_message_resolves( textid = zasis_cx_exc=>http_request_read_error ).
  ENDMETHOD.

  METHOD test_http_status_default.
    DATA(exc) = NEW zasis_cx_exc( textid = zasis_cx_exc=>unknown_ruleset ).
    cl_abap_unit_assert=>assert_equals(
      act = exc->http_status
      exp = '400' ).
  ENDMETHOD.

  METHOD test_http_status_custom.
    DATA(exc) = NEW zasis_cx_exc( textid      = zasis_cx_exc=>method_not_supported
                                  http_status = '405' ).
    cl_abap_unit_assert=>assert_equals(
      act = exc->http_status
      exp = '405' ).
  ENDMETHOD.

ENDCLASS.

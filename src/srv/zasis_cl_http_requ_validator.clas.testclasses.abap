*"* use this source file for your ABAP unit test classes

CLASS ltcl_mock_request DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zasis_if_http_request.
    DATA mock_path TYPE string.
    DATA mock_method TYPE string.
    DATA mock_body TYPE string.
    DATA mock_content_type TYPE string.
ENDCLASS.

CLASS ltcl_mock_request IMPLEMENTATION.
  METHOD zasis_if_http_request~get_path.
    path = mock_path.
  ENDMETHOD.

  METHOD zasis_if_http_request~get_method.
    method = mock_method.
  ENDMETHOD.

  METHOD zasis_if_http_request~get_header_field.
    IF name = 'content-type'.
      value = mock_content_type.
    ELSE.
      value = ||.
    ENDIF.
  ENDMETHOD.

  METHOD zasis_if_http_request~get_body_text.
    text = mock_body.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_validator DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA mock TYPE REF TO ltcl_mock_request.
    DATA cut  TYPE REF TO zasis_cl_http_requ_validator.

    METHODS setup.

    METHODS test_extract_ruleset_id FOR TESTING RAISING zasis_cx_exc.
    METHODS test_extract_deep_path FOR TESTING RAISING zasis_cx_exc.
    METHODS test_empty_path_raises FOR TESTING.
    METHODS test_single_segment_raises FOR TESTING.
    METHODS test_invalid_route_raises FOR TESTING.
    METHODS test_empty_ruleset_id_raises FOR TESTING.
    METHODS test_validate_content_type_ok FOR TESTING RAISING zasis_cx_exc.
    METHODS test_content_type_wrong_raises FOR TESTING.
    METHODS test_content_type_empty_raises FOR TESTING.
ENDCLASS.

CLASS ltcl_validator IMPLEMENTATION.

  METHOD setup.
    mock = NEW #( ).
    mock->mock_path = '/ruleSetExecution/MyRuleSet'.
    mock->mock_content_type = 'application/json'.
    cut = NEW zasis_cl_http_requ_validator( request = mock ).
  ENDMETHOD.

  METHOD test_extract_ruleset_id.
    DATA(id) = cut->extract_ruleset_id( ).
    cl_abap_unit_assert=>assert_equals(
      act = id
      exp = 'MyRuleSet' ).
  ENDMETHOD.

  METHOD test_extract_deep_path.
    mock->mock_path = '/sap/bc/zasis/ruleSet/DeepRS'.
    cut = NEW zasis_cl_http_requ_validator( request = mock ).
    DATA(id) = cut->extract_ruleset_id( ).
    cl_abap_unit_assert=>assert_equals(
      act = id
      exp = 'DeepRS' ).
  ENDMETHOD.

  METHOD test_empty_path_raises.
    mock->mock_path = ''.
    cut = NEW zasis_cl_http_requ_validator( request = mock ).
    TRY.
        cut->extract_ruleset_id( ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception' ).
      CATCH zasis_cx_exc INTO DATA(exc).
        cl_abap_unit_assert=>assert_equals(
          act = exc->if_t100_message~t100key-msgno
          exp = '005' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_single_segment_raises.
    mock->mock_path = '/onlyOneSegment'.
    cut = NEW zasis_cl_http_requ_validator( request = mock ).
    TRY.
        cut->extract_ruleset_id( ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception' ).
      CATCH zasis_cx_exc INTO DATA(exc).
        cl_abap_unit_assert=>assert_equals(
          act = exc->if_t100_message~t100key-msgno
          exp = '005' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_invalid_route_raises.
    mock->mock_path = '/invalidRoute/MyRuleSet'.
    cut = NEW zasis_cl_http_requ_validator( request = mock ).
    TRY.
        cut->extract_ruleset_id( ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception' ).
      CATCH zasis_cx_exc INTO DATA(exc).
        cl_abap_unit_assert=>assert_equals(
          act = exc->if_t100_message~t100key-msgno
          exp = '005' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_empty_ruleset_id_raises.
    mock->mock_path = '/ruleSetExecution/'.
    cut = NEW zasis_cl_http_requ_validator( request = mock ).
    TRY.
        cut->extract_ruleset_id( ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception' ).
      CATCH zasis_cx_exc INTO DATA(exc).
        cl_abap_unit_assert=>assert_equals(
          act = exc->if_t100_message~t100key-msgno
          exp = '005' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_validate_content_type_ok.
    cut->validate_content_type( ).
  ENDMETHOD.

  METHOD test_content_type_wrong_raises.
    mock->mock_content_type = 'text/plain'.
    TRY.
        cut->validate_content_type( ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception' ).
      CATCH zasis_cx_exc INTO DATA(exc).
        cl_abap_unit_assert=>assert_equals(
          act = exc->if_t100_message~t100key-msgno
          exp = '006' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_content_type_empty_raises.
    mock->mock_content_type = ''.
    TRY.
        cut->validate_content_type( ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception' ).
      CATCH zasis_cx_exc INTO DATA(exc).
        cl_abap_unit_assert=>assert_equals(
          act = exc->if_t100_message~t100key-msgno
          exp = '006' ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

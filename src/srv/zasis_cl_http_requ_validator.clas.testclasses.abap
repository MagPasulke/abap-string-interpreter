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
    METHODS test_bulk_route FOR TESTING RAISING zasis_cx_exc.
    METHODS test_non_bulk_route FOR TESTING RAISING zasis_cx_exc.
    METHODS test_bulk_wrong_res_raises FOR TESTING.
    METHODS test_ruleset_named_bulk FOR TESTING RAISING zasis_cx_exc.
    METHODS test_bulk_count_empty_raises FOR TESTING.
    METHODS test_bulk_count_over_max FOR TESTING.
    METHODS test_bulk_count_max_ok FOR TESTING RAISING zasis_cx_exc.
    METHODS test_bulk_ids_ok FOR TESTING RAISING zasis_cx_exc.
    METHODS test_bulk_id_empty_raises FOR TESTING.
    METHODS test_bulk_id_duplicate_raises FOR TESTING.
    METHODS test_bulk_id_blank_raises FOR TESTING.
    METHODS test_bulk_id_first_offender FOR TESTING.

    METHODS assert_raises_bulk_count
      IMPORTING
        item_count TYPE i
        exp_msgno  TYPE symsgno
      RETURNING
        VALUE(exc) TYPE REF TO zasis_cx_exc.

    METHODS assert_raises_bulk_ids
      IMPORTING
        item_ids   TYPE string_table
        exp_msgno  TYPE symsgno
      RETURNING
        VALUE(exc) TYPE REF TO zasis_cx_exc.
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

  METHOD test_bulk_route.
    mock->mock_path = '/sap/bc/zasis/ruleSetExecution/MyRuleSet/bulk'.
    cut = NEW zasis_cl_http_requ_validator( request = mock ).
    DATA(id) = cut->extract_ruleset_id( ).
    cl_abap_unit_assert=>assert_equals(
      act = id
      exp = 'MyRuleSet' ).
    cl_abap_unit_assert=>assert_true( cut->is_bulk ).
  ENDMETHOD.

  METHOD test_non_bulk_route.
    cut->extract_ruleset_id( ).
    cl_abap_unit_assert=>assert_false( cut->is_bulk ).
  ENDMETHOD.

  METHOD test_ruleset_named_bulk.
    mock->mock_path = '/sap/bc/zasis/ruleSetExecution/bulk'.
    cut = NEW zasis_cl_http_requ_validator( request = mock ).
    DATA(id) = cut->extract_ruleset_id( ).
    cl_abap_unit_assert=>assert_equals(
      act = id
      exp = 'bulk' ).
    cl_abap_unit_assert=>assert_false( cut->is_bulk ).
  ENDMETHOD.

  METHOD test_bulk_wrong_res_raises.
    mock->mock_path = '/ruleSet/MyRuleSet/bulk'.
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

  METHOD assert_raises_bulk_count.
    TRY.
        cut->validate_bulk_item_count( item_count ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception' ).
      CATCH zasis_cx_exc INTO exc.
        cl_abap_unit_assert=>assert_equals(
          act = exc->if_t100_message~t100key-msgno
          exp = exp_msgno ).
        cl_abap_unit_assert=>assert_equals(
          act = exc->http_status
          exp = '400' ).
    ENDTRY.
  ENDMETHOD.

  METHOD assert_raises_bulk_ids.
    TRY.
        cut->validate_bulk_item_ids( item_ids ).
        cl_abap_unit_assert=>fail( msg = 'Expected exception' ).
      CATCH zasis_cx_exc INTO exc.
        cl_abap_unit_assert=>assert_equals(
          act = exc->if_t100_message~t100key-msgno
          exp = exp_msgno ).
        cl_abap_unit_assert=>assert_equals(
          act = exc->http_status
          exp = '400' ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_bulk_count_empty_raises.
    assert_raises_bulk_count( item_count = 0
                              exp_msgno  = zasis_cx_exc=>bulk_items_empty-msgno ).
  ENDMETHOD.

  METHOD test_bulk_count_over_max.
    DATA(exc) = assert_raises_bulk_count( item_count = zasis_constants=>bulk-max_items + 1
                                          exp_msgno  = zasis_cx_exc=>bulk_too_many_items-msgno ).
    cl_abap_unit_assert=>assert_equals(
      act = exc->max_items
      exp = zasis_constants=>bulk-max_items ).
  ENDMETHOD.

  METHOD test_bulk_count_max_ok.
    cut->validate_bulk_item_count( zasis_constants=>bulk-max_items ).
    cut->validate_bulk_item_count( 1 ).
  ENDMETHOD.

  METHOD test_bulk_ids_ok.
    cut->validate_bulk_item_ids( VALUE #( ( `a` ) ( `b` ) ( `c` ) ) ).
  ENDMETHOD.

  METHOD test_bulk_id_empty_raises.
    DATA(exc) = assert_raises_bulk_ids( item_ids  = VALUE #( ( `a` ) ( `` ) ( `c` ) )
                                        exp_msgno = zasis_cx_exc=>bulk_item_id_missing-msgno ).
    cl_abap_unit_assert=>assert_equals(
      act = exc->item_position
      exp = 2 ).
  ENDMETHOD.

  METHOD test_bulk_id_duplicate_raises.
    DATA(exc) = assert_raises_bulk_ids( item_ids  = VALUE #( ( `a` ) ( `b` ) ( `a` ) )
                                        exp_msgno = zasis_cx_exc=>bulk_item_id_duplicate-msgno ).
    cl_abap_unit_assert=>assert_equals(
      act = exc->item_id
      exp = `a` ).
  ENDMETHOD.

  METHOD test_bulk_id_blank_raises.
    DATA(exc) = assert_raises_bulk_ids( item_ids  = VALUE #( ( `a` ) ( `  ` ) )
                                        exp_msgno = zasis_cx_exc=>bulk_item_id_missing-msgno ).
    cl_abap_unit_assert=>assert_equals(
      act = exc->item_position
      exp = 2 ).
  ENDMETHOD.

  METHOD test_bulk_id_first_offender.
    DATA(exc) = assert_raises_bulk_ids( item_ids  = VALUE #( ( `a` ) ( `b` ) ( `b` ) ( `a` ) ( `` ) )
                                        exp_msgno = zasis_cx_exc=>bulk_item_id_duplicate-msgno ).
    cl_abap_unit_assert=>assert_equals(
      act = exc->item_id
      exp = `b` ).
  ENDMETHOD.

ENDCLASS.

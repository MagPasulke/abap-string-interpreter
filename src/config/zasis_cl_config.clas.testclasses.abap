CLASS ltcl_config DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA sql_environment TYPE REF TO if_osql_test_environment.

    DATA cut TYPE REF TO zasis_if_config.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS no_row_falls_back FOR TESTING.
    METHODS non_numeric_falls_back FOR TESTING.
    METHODS decimal_falls_back FOR TESTING.
    METHODS zero_falls_back FOR TESTING.
    METHODS negative_falls_back FOR TESTING.
    METHODS overflow_falls_back FOR TESTING.
    METHODS valid_value_is_used FOR TESTING.
    METHODS padded_value_is_used FOR TESTING.

    METHODS given_bulk_max_items
      IMPORTING
        value TYPE zasis_config_value.

    METHODS assert_bulk_max_items
      IMPORTING
        exp TYPE i.
ENDCLASS.

CLASS ltcl_config IMPLEMENTATION.

  METHOD class_setup.
    sql_environment = cl_osql_test_environment=>create( VALUE #( ( 'ZASIS_CONFIG' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    sql_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    sql_environment->clear_doubles( ).
    cut = NEW zasis_cl_config( ).
  ENDMETHOD.

  METHOD given_bulk_max_items.
    DATA config_rows TYPE STANDARD TABLE OF zasis_config WITH EMPTY KEY.
    config_rows = VALUE #( ( config_key   = 'BULK_MAX'
                             config_value = value ) ).
    sql_environment->insert_test_data( config_rows ).
  ENDMETHOD.

  METHOD assert_bulk_max_items.
    cl_abap_unit_assert=>assert_equals( act = cut->get_bulk_max_items( )
                                        exp = exp ).
  ENDMETHOD.

  METHOD no_row_falls_back.
    assert_bulk_max_items( zasis_constants=>bulk-max_items ).
  ENDMETHOD.

  METHOD non_numeric_falls_back.
    given_bulk_max_items( 'abc' ).
    assert_bulk_max_items( zasis_constants=>bulk-max_items ).
  ENDMETHOD.

  METHOD decimal_falls_back.
    given_bulk_max_items( '10.5' ).
    assert_bulk_max_items( zasis_constants=>bulk-max_items ).
  ENDMETHOD.

  METHOD zero_falls_back.
    given_bulk_max_items( '0' ).
    assert_bulk_max_items( zasis_constants=>bulk-max_items ).
  ENDMETHOD.

  METHOD negative_falls_back.
    given_bulk_max_items( '-5' ).
    assert_bulk_max_items( zasis_constants=>bulk-max_items ).
  ENDMETHOD.

  METHOD overflow_falls_back.
    given_bulk_max_items( '99999999999999999999' ).
    assert_bulk_max_items( zasis_constants=>bulk-max_items ).
  ENDMETHOD.

  METHOD valid_value_is_used.
    given_bulk_max_items( '200' ).
    assert_bulk_max_items( 200 ).
  ENDMETHOD.

  METHOD padded_value_is_used.
    given_bulk_max_items( '  7' ).
    assert_bulk_max_items( 7 ).
  ENDMETHOD.

ENDCLASS.

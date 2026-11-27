CLASS ltcl_config DEFINITION DEFERRED.
CLASS zasis_cl_config DEFINITION LOCAL FRIENDS ltcl_config.

CLASS ltcl_config DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS fallback TYPE i VALUE 50.

    DATA cut TYPE REF TO zasis_cl_config.

    METHODS setup.

    METHODS no_row_falls_back FOR TESTING.
    METHODS non_numeric_falls_back FOR TESTING.
    METHODS decimal_falls_back FOR TESTING.
    METHODS zero_falls_back FOR TESTING.
    METHODS negative_falls_back FOR TESTING.
    METHODS overflow_falls_back FOR TESTING.
    METHODS valid_value_is_used FOR TESTING.
    METHODS padded_value_is_used FOR TESTING.

    METHODS assert_converts
      IMPORTING
        value TYPE zasis_config_value
        exp   TYPE i.
ENDCLASS.

CLASS ltcl_config IMPLEMENTATION.

  METHOD setup.
    cut = NEW #( ).
  ENDMETHOD.

  METHOD assert_converts.
    cl_abap_unit_assert=>assert_equals( act = cut->to_positive_int( value    = value
                                                                    fallback = fallback )
                                        exp = exp
                                        msg = |Value '{ value }'| ).
  ENDMETHOD.

  METHOD no_row_falls_back.
    " read_value returns an initial value if no row exists
    assert_converts( value = ''
                     exp   = fallback ).
  ENDMETHOD.

  METHOD non_numeric_falls_back.
    assert_converts( value = 'abc'
                     exp   = fallback ).
  ENDMETHOD.

  METHOD decimal_falls_back.
    assert_converts( value = '10.5'
                     exp   = fallback ).
  ENDMETHOD.

  METHOD zero_falls_back.
    assert_converts( value = '0'
                     exp   = fallback ).
  ENDMETHOD.

  METHOD negative_falls_back.
    assert_converts( value = '-5'
                     exp   = fallback ).
  ENDMETHOD.

  METHOD overflow_falls_back.
    assert_converts( value = '99999999999999999999'
                     exp   = fallback ).
  ENDMETHOD.

  METHOD valid_value_is_used.
    assert_converts( value = '200'
                     exp   = 200 ).
  ENDMETHOD.

  METHOD padded_value_is_used.
    assert_converts( value = '  7'
                     exp   = 7 ).
  ENDMETHOD.

ENDCLASS.

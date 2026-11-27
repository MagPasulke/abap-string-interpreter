CLASS zasis_cl_config DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zasis_if_config.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF config_key,
        bulk_max_items TYPE zasis_config_key VALUE 'BULK_MAX_ITEMS',
      END OF config_key.

    "! Reads a config value by key; returns an initial value if no row exists
    METHODS read_value
      IMPORTING
        key          TYPE zasis_config_key
      RETURNING
        VALUE(value) TYPE zasis_config_value.

    "! Converts a value to a positive integer, returns the fallback if not possible
    METHODS to_positive_int
      IMPORTING
        value         TYPE zasis_config_value
        fallback      TYPE i
      RETURNING
        VALUE(result) TYPE i.

ENDCLASS.



CLASS zasis_cl_config IMPLEMENTATION.

  METHOD zasis_if_config~get_bulk_max_items.
    max_items = to_positive_int( value    = read_value( config_key-bulk_max_items )
                                 fallback = zasis_constants=>bulk-max_items ).
  ENDMETHOD.

  METHOD read_value.
    SELECT SINGLE config_value FROM zasis_config
      WHERE config_key = @key
      INTO @value.
    IF sy-subrc <> 0.
      CLEAR value.
    ENDIF.
  ENDMETHOD.

  METHOD to_positive_int.
    result = fallback.

    DATA(condensed) = condense( value ).
    " max. 9 digits always fits into type i, no overflow possible
    IF NOT matches( val  = condensed
                    pcre = `^\d{1,9}$` ).
      RETURN.
    ENDIF.

    DATA(number) = CONV i( condensed ).
    IF number > 0.
      result = number.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

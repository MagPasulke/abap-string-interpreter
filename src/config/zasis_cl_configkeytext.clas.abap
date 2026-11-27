CLASS zasis_cl_configkeytext DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_configkeytext IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    TYPES: BEGIN OF ty_config,
             configkey     TYPE zasis_config_key,
             configkeytext TYPE c LENGTH 60,
           END OF ty_config.

    DATA original_data TYPE STANDARD TABLE OF ty_config.

    original_data = CORRESPONDING #( it_original_data ).

    CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZASIS_CONFIG_KEY' ) )->get_ddic_fixed_values(
      EXPORTING  p_langu        = sy-langu
      RECEIVING  p_fixed_values = DATA(fixed_values)
      EXCEPTIONS not_found      = 1
                 no_ddic_type   = 2
                 OTHERS         = 3 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT original_data ASSIGNING FIELD-SYMBOL(<line>).

      READ TABLE fixed_values WITH KEY low = <line>-configkey INTO DATA(domain_value).
      IF sy-subrc = 0.
        <line>-configkeytext = domain_value-ddtext.
      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.

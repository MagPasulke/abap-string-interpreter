CLASS zasis_cl_catstattext DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_catstattext IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    TYPES: BEGIN OF ty_stat,
             status     TYPE zasis_cat_stat,
             statustext TYPE c LENGTH 20,
           END OF ty_stat.

    DATA original_data TYPE STANDARD TABLE OF ty_stat.

    original_data = CORRESPONDING #( it_original_data ).

    CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZASIS_CAT_STAT' ) )->get_ddic_fixed_values(
      EXPORTING  p_langu        = sy-langu
      RECEIVING  p_fixed_values = DATA(fixed_values)
      EXCEPTIONS not_found      = 1
                 no_ddic_type   = 2
                 OTHERS         = 3 ).

    LOOP AT original_data ASSIGNING FIELD-SYMBOL(<line>).

      READ TABLE fixed_values WITH KEY low = <line>-status INTO DATA(domain_value).
      IF sy-subrc = 0.
        <line>-statustext = domain_value-ddtext.
      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.

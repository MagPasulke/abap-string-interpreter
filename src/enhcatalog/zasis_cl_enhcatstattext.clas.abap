CLASS zasis_cl_enhcatstattext DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_enhcatstattext IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA original_data TYPE STANDARD TABLE OF zasis_c_custlogcatalog.

    original_data = CORRESPONDING #( it_original_data ).

    SELECT domvalue_l, ddtext
      FROM dd07t
      WHERE ddlanguage = @sy-langu AND domname = 'ZASIS_ENHCAT_STAT'
      ORDER BY domvalue_l
      INTO TABLE @DATA(domain_values).

    IF sy-subrc = 0.

      LOOP AT original_data ASSIGNING FIELD-SYMBOL(<line>).

        READ TABLE domain_values WITH KEY domvalue_l = <line>-status INTO DATA(domain_value).
        IF sy-subrc = 0.
          <line>-statustext = domain_value-ddtext.
        ENDIF.

      ENDLOOP.

    ENDIF.

    ct_calculated_data = CORRESPONDING #( original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.

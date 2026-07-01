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

    SELECT domvalue_l, ddtext
      FROM dd07t
      WHERE ddlanguage = @sy-langu AND domname = 'ZASIS_CAT_STAT'
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

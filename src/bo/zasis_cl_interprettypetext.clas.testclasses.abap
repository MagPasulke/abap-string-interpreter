CLASS ltcl_interprettypetext DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_item,
             interpretationtype     TYPE zasis_ruleitem_type,
             interpretationtypetext TYPE c LENGTH 10,
           END OF ty_item,
           ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    METHODS fills_text_for_known_types FOR TESTING RAISING cx_static_check.
    METHODS keeps_text_empty_for_unknown FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_interprettypetext IMPLEMENTATION.

  METHOD fills_text_for_known_types.
    DATA calculated TYPE ty_items.
    DATA(cut) = NEW zasis_cl_interprettypetext( ).

    cut->if_sadl_exit_calc_element_read~calculate(
      EXPORTING it_original_data           = VALUE ty_items( ( interpretationtype = '1' )
                                                             ( interpretationtype = '2' ) )
                it_requested_calc_elements = VALUE #( )
      CHANGING  ct_calculated_data         = calculated ).

    cl_abap_unit_assert=>assert_equals( act = calculated[ 1 ]-interpretationtypetext
                                        exp = 'Match' ).
    cl_abap_unit_assert=>assert_equals( act = calculated[ 2 ]-interpretationtypetext
                                        exp = 'Replace' ).
  ENDMETHOD.

  METHOD keeps_text_empty_for_unknown.
    DATA calculated TYPE ty_items.
    DATA(cut) = NEW zasis_cl_interprettypetext( ).

    cut->if_sadl_exit_calc_element_read~calculate(
      EXPORTING it_original_data           = VALUE ty_items( ( interpretationtype = '9' ) )
                it_requested_calc_elements = VALUE #( )
      CHANGING  ct_calculated_data         = calculated ).

    cl_abap_unit_assert=>assert_initial( calculated[ 1 ]-interpretationtypetext ).
  ENDMETHOD.

ENDCLASS.

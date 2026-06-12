CLASS zasis_cl_calc_export_url DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_calc_export_url IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    CHECK iv_entity = 'ZASIS_C_RULESET'.

    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<calc_element>).
      CASE <calc_element>.
        WHEN 'EXPORTURL'.
          INSERT `RULESETID` INTO TABLE et_requested_orig_elements.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA calculated TYPE STANDARD TABLE OF zasis_c_ruleset WITH DEFAULT KEY.
    calculated = CORRESPONDING #( it_original_data ).

    LOOP AT calculated ASSIGNING FIELD-SYMBOL(<row>).
      <row>-exporturl = |/sap/bc/http/sap/zasis_ext_api_cld/{ zasis_constants=>export-resource_path }/{ <row>-rulesetid }|.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( calculated ).
  ENDMETHOD.

ENDCLASS.

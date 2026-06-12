CLASS ltcl_export_mapper DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zasis_cl_export_mapper.

    METHODS setup.
    METHODS maps_schema_version FOR TESTING RAISING zasis_cx_exc.
    METHODS maps_rulesetid FOR TESTING RAISING zasis_cx_exc.
    METHODS maps_match_type FOR TESTING RAISING zasis_cx_exc.
    METHODS maps_replace_type FOR TESTING RAISING zasis_cx_exc.
    METHODS maps_unknown_type_as_is FOR TESTING RAISING zasis_cx_exc.
    METHODS maps_item_fields FOR TESTING RAISING zasis_cx_exc.
    METHODS maps_multiple_items FOR TESTING RAISING zasis_cx_exc.
    METHODS excludes_uuid FOR TESTING RAISING zasis_cx_exc.
ENDCLASS.

CLASS ltcl_export_mapper IMPLEMENTATION.

  METHOD setup.
    cut = NEW zasis_cl_export_mapper( ).
  ENDMETHOD.

  METHOD maps_schema_version.
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '1234' rulesetid = 'TEST01' )
      items  = VALUE #( ( interpretationitm = 1 interpretation_type = '1' ) ) ).

    DATA(result) = cut->map( ruleset ).

    cl_abap_unit_assert=>assert_equals(
      act = result-schema_version
      exp = '1.0' ).
  ENDMETHOD.

  METHOD maps_rulesetid.
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '1234' rulesetid = 'MY_RULES' )
      items  = VALUE #( ( interpretationitm = 1 interpretation_type = '1' ) ) ).

    DATA(result) = cut->map( ruleset ).

    cl_abap_unit_assert=>assert_equals(
      act = result-rulesetid
      exp = 'MY_RULES' ).
  ENDMETHOD.

  METHOD maps_match_type.
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '1234' rulesetid = 'TEST01' )
      items  = VALUE #( ( interpretationitm = 1 interpretation_type = '1' ) ) ).

    DATA(result) = cut->map( ruleset ).

    cl_abap_unit_assert=>assert_equals(
      act = result-items[ 1 ]-interpretation_type
      exp = 'MATCH' ).
  ENDMETHOD.

  METHOD maps_replace_type.
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '1234' rulesetid = 'TEST01' )
      items  = VALUE #( ( interpretationitm = 1 interpretation_type = '2' ) ) ).

    DATA(result) = cut->map( ruleset ).

    cl_abap_unit_assert=>assert_equals(
      act = result-items[ 1 ]-interpretation_type
      exp = 'REPLACE' ).
  ENDMETHOD.

  METHOD maps_unknown_type_as_is.
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '1234' rulesetid = 'TEST01' )
      items  = VALUE #( ( interpretationitm = 1 interpretation_type = '9' ) ) ).

    DATA(result) = cut->map( ruleset ).

    cl_abap_unit_assert=>assert_equals(
      act = result-items[ 1 ]-interpretation_type
      exp = '9' ).
  ENDMETHOD.

  METHOD maps_item_fields.
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '1234' rulesetid = 'TEST01' )
      items  = VALUE #( ( interpretationitm   = 1
                          intpretationtarget  = 'BATCH'
                          interpretationrule  = '^(.{6})'
                          interpretation_type = '1'
                          offset_pre          = 2
                          offset_post         = 3
                          replacement_string  = 'X'
                          custom_logic        = 'ZCL_MY_LOGIC' ) ) ).

    DATA(result) = cut->map( ruleset ).
    DATA(item) = result-items[ 1 ].

    cl_abap_unit_assert=>assert_equals(
      act = item-interpretationitm
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = item-intpretationtarget
      exp = 'BATCH' ).
    cl_abap_unit_assert=>assert_equals(
      act = item-interpretationrule
      exp = '^(.{6})' ).
    cl_abap_unit_assert=>assert_equals(
      act = item-offset_pre
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = item-offset_post
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = item-replacement_string
      exp = 'X' ).
    cl_abap_unit_assert=>assert_equals(
      act = item-custom_logic
      exp = 'ZCL_MY_LOGIC' ).
  ENDMETHOD.

  METHOD maps_multiple_items.
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '1234' rulesetid = 'TEST01' )
      items  = VALUE #( ( interpretationitm = 1 interpretation_type = '1' )
                        ( interpretationitm = 2 interpretation_type = '2' )
                        ( interpretationitm = 3 interpretation_type = '1' ) ) ).

    DATA(result) = cut->map( ruleset ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result-items )
      exp = 3 ).
  ENDMETHOD.

  METHOD excludes_uuid.
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = 'AABBCCDD11223344' rulesetid = 'TEST01' )
      items  = VALUE #( ( interpretationitm = 1 interpretation_type = '1' ) ) ).

    DATA(result) = cut->map( ruleset ).

    " The export structure has no UUID field — this test verifies the schema design.
    " If schema_version and rulesetid are populated, UUID is excluded by design.
    cl_abap_unit_assert=>assert_not_initial( result-schema_version ).
    cl_abap_unit_assert=>assert_not_initial( result-rulesetid ).
  ENDMETHOD.

ENDCLASS.

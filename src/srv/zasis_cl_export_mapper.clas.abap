CLASS zasis_cl_export_mapper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Maps a ruleset to the export DTO structure
    METHODS map
      IMPORTING
        ruleset       TYPE REF TO zasis_if_ruleset
      RETURNING
        VALUE(result) TYPE zasis_srv_export.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS map_type
      IMPORTING
        db_type       TYPE zasis_ruleitem_type
      RETURNING
        VALUE(result) TYPE string.
ENDCLASS.



CLASS zasis_cl_export_mapper IMPLEMENTATION.

  METHOD map.
    result-schema_version = zasis_constants=>export-schema_version.
    result-rulesetid = ruleset->header-rulesetid.

    LOOP AT ruleset->items INTO DATA(item).
      APPEND VALUE zasis_srv_export_itm(
        intpretationtarget  = item-intpretationtarget
        interpretationrule  = item-interpretationrule
        interpretation_type = map_type( item-interpretation_type )
        offset_pre          = item-offset_pre
        offset_post         = item-offset_post
        replacement_string  = item-replacement_string
        custom_logic        = item-custom_logic
      ) TO result-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_type.
    CASE db_type.
      WHEN zasis_constants=>ruleitem_type-match.
        result = zasis_constants=>export_type-match.
      WHEN zasis_constants=>ruleitem_type-replace.
        result = zasis_constants=>export_type-replace.
      WHEN OTHERS.
        result = db_type.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

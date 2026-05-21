CLASS zasis_cx_exc DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_t100_message.

    CONSTANTS: BEGIN OF invalid_api_route,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '005',
                 attr1 TYPE scx_attrname VALUE 'ROUTE',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF invalid_api_route.

    CONSTANTS: BEGIN OF content_not_json,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '006',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF content_not_json.

    CONSTANTS: BEGIN OF unknown_ruleset,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '007',
                 attr1 TYPE scx_attrname VALUE 'RULESET',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF unknown_ruleset.

    CONSTANTS: BEGIN OF invalid_interpretation_type,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '008',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF invalid_interpretation_type.

    CONSTANTS: BEGIN OF error_custom_log_processing,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '009',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF error_custom_log_processing.

    CONSTANTS: BEGIN OF class_no_intf,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '003',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF class_no_intf.

    CONSTANTS: BEGIN OF class_not_exist,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '004',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF class_not_exist.

    CONSTANTS: BEGIN OF string_to_interpret_empty,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '015',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF string_to_interpret_empty.

    METHODS constructor
      IMPORTING textid    LIKE if_t100_message=>t100key OPTIONAL
                !previous LIKE previous                 OPTIONAL
                !route    TYPE string                   OPTIONAL
                !ruleset  TYPE zasis_ruleset_id OPTIONAL.

    DATA route TYPE string READ-ONLY.
    DATA ruleset  TYPE zasis_ruleset_id READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cx_exc IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->route = route.
    me->ruleset = ruleset.

  ENDMETHOD.
ENDCLASS.

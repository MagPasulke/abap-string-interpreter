CLASS zasis_cx_ruleset_ui DEFINITION
  PUBLIC
  INHERITING FROM zasis_cx_exc
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_abap_behv_message.
    INTERFACES if_t100_message.

    CONSTANTS: BEGIN OF duplicate_rulesetid,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '001',
                 attr1 TYPE scx_attrname VALUE 'RULESETID',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF duplicate_rulesetid.

    CONSTANTS: BEGIN OF invalid_regex,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '002',
                 attr1 TYPE scx_attrname VALUE 'REGEX',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF invalid_regex.

    CONSTANTS: BEGIN OF no_auth,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '010',
                 attr1 TYPE scx_attrname VALUE 'ACTION',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
                END OF no_auth.

    CONSTANTS: BEGIN OF event_producer_not_exist,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '011',
                 attr1 TYPE scx_attrname VALUE 'CLASSNAME',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF event_producer_not_exist.

    CONSTANTS: BEGIN OF event_producer_no_intf,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '012',
                 attr1 TYPE scx_attrname VALUE 'CLASSNAME',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF event_producer_no_intf.

    CONSTANTS: BEGIN OF custom_logic_not_exist,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '013',
                 attr1 TYPE scx_attrname VALUE 'CLASSNAME',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF custom_logic_not_exist.

    CONSTANTS: BEGIN OF custom_logic_no_intf,
                 msgid TYPE symsgid      VALUE 'ZASIS_MSGS',
                 msgno TYPE symsgno      VALUE '014',
                 attr1 TYPE scx_attrname VALUE 'CLASSNAME',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF custom_logic_no_intf.

    METHODS constructor
      IMPORTING severity  TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
                textid    LIKE if_t100_message=>t100key         OPTIONAL
                !previous LIKE previous                         OPTIONAL
                rulesetid TYPE zasis_ruleset_id                 OPTIONAL
                !regex    TYPE zasis_interpretrule              OPTIONAL
                classname TYPE zasis_customlogic                OPTIONAL
                !action   TYPE string                           OPTIONAL.

    DATA rulesetid TYPE zasis_ruleset_id    READ-ONLY.
    DATA regex     TYPE zasis_interpretrule READ-ONLY.
    DATA action    TYPE string              READ-ONLY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cx_ruleset_ui IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous classname = classname ).
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    if_abap_behv_message~m_severity = severity.
    me->rulesetid = rulesetid.
    me->regex = regex.
    me->action = action.
  ENDMETHOD.
ENDCLASS.

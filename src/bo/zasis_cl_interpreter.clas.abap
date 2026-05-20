CLASS zasis_cl_interpreter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zasis_if_interpreter.

    ALIASES execute FOR zasis_if_interpreter~execute.

    METHODS constructor
      IMPORTING
        auth_checker           TYPE REF TO zasis_if_auth_checker OPTIONAL
        event_producer_resolver TYPE REF TO zasis_if_ev_producer_resolver OPTIONAL
        customlogic_resolver   TYPE REF TO zasis_if_customlogic_resolver OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA auth_checker TYPE REF TO zasis_if_auth_checker.
    DATA event_producer_resolver TYPE REF TO zasis_if_ev_producer_resolver.
    DATA customlogic_resolver TYPE REF TO zasis_if_customlogic_resolver.

    METHODS call_custom_logic
      IMPORTING
        custom_logic_class           TYPE zasis_customlogic
        ruleset_ref                  TYPE REF TO zasis_if_ruleset
        current_rule_item            TYPE zasis_rulesetitm
        string_to_be_interpreted     TYPE string
        context                      TYPE zasis_tt_interpret_context OPTIONAL
      RETURNING
        VALUE(interpretation_result) TYPE string
      RAISING
        zasis_cx_exc.

    METHODS call_event_producer
      IMPORTING
        event_producer_class  TYPE zasis_event_producer
        ruleset_ref           TYPE REF TO zasis_if_ruleset
        interpretation_itm    TYPE zasis_ruleset_item
        interpretation_result TYPE zasis_interpret_result_line
        context               TYPE zasis_tt_interpret_context OPTIONAL.
ENDCLASS.



CLASS zasis_cl_interpreter IMPLEMENTATION.


  METHOD constructor.
    IF auth_checker IS BOUND.
      me->auth_checker = auth_checker.
    ELSE.
      me->auth_checker = NEW zasis_cl_auth_checker( ).
    ENDIF.

    IF event_producer_resolver IS BOUND.
      me->event_producer_resolver = event_producer_resolver.
    ELSE.
      me->event_producer_resolver = NEW zasis_cl_ev_producer_resolver( ).
    ENDIF.

    IF customlogic_resolver IS BOUND.
      me->customlogic_resolver = customlogic_resolver.
    ELSE.
      me->customlogic_resolver = NEW zasis_cl_customlogic_resolver( ).
    ENDIF.
  ENDMETHOD.


  METHOD zasis_if_interpreter~execute.
    DATA single_interpret_result TYPE string.

    "check auth first
    me->auth_checker->check_execute( ruleset_id = ruleset->header-rulesetid ).

    LOOP AT ruleset->items INTO DATA(rulesetitem).

      CLEAR single_interpret_result.

      "in case custom logic is assigned, no need for regular processing
      IF rulesetitem-custom_logic IS NOT INITIAL.

        single_interpret_result = me->call_custom_logic(  custom_logic_class       = rulesetitem-custom_logic
                                                          ruleset_ref             = ruleset
                                                          current_rule_item       = rulesetitem
                                                          string_to_be_interpreted = string_to_be_interpreted
                                                          context                 = context ).

      ELSE.

        CASE rulesetitem-interpretation_type.

          WHEN zasis_constants=>ruleitem_type-match.

            DATA(regex_trimmed) = condense( rulesetitem-interpretationrule ).
            DATA(result_before_offset) = match( val   = string_to_be_interpreted
                                                regex = regex_trimmed ).

            IF result_before_offset IS NOT INITIAL.

              DATA(length) = strlen( result_before_offset ).
              length = length - rulesetitem-offset_post - rulesetitem-offset_pre.

              single_interpret_result = result_before_offset+rulesetitem-offset_pre(length).

            ENDIF.

          WHEN zasis_constants=>ruleitem_type-replace.

            " no offsets applied to replacements
            DATA(result_replace) = replace( val   = string_to_be_interpreted
                                            regex = condense( rulesetitem-interpretationrule )
                                            with  = rulesetitem-replacement_string ).

            single_interpret_result = result_replace.

          WHEN OTHERS.

            RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_interpretation_type ).

        ENDCASE.

      ENDIF.

      IF single_interpret_result IS NOT INITIAL.

        APPEND INITIAL LINE TO interpretation_result ASSIGNING FIELD-SYMBOL(<result_line>).
        IF sy-subrc = 0.
          <result_line>-targetfield          = rulesetitem-intpretationtarget.
          <result_line>-interpretationresult = single_interpret_result.
        ENDIF.

        IF rulesetitem-event_producer IS NOT INITIAL.
          me->call_event_producer( event_producer_class  = rulesetitem-event_producer
                                   ruleset_ref           = ruleset
                                   interpretation_itm    = rulesetitem-interpretationitm
                                   interpretation_result = <result_line>
                                   context               = context ).
        ENDIF.

      ELSE.

        APPEND INITIAL LINE TO interpretation_result ASSIGNING FIELD-SYMBOL(<no_result_line>).
        IF sy-subrc = 0.
          <no_result_line>-targetfield          = rulesetitem-intpretationtarget.
          <no_result_line>-interpretationresult = `no match`.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD call_custom_logic.

    DATA(instance) = me->customlogic_resolver->resolve( custom_logic_class ).

    interpretation_result = instance->execute(
      string_to_be_interpretet = string_to_be_interpreted
      ruleset                  = ruleset_ref
      current_rule_item        = current_rule_item
      context                  = context ).

  ENDMETHOD.


  METHOD call_event_producer.

    TRY.
        DATA(producer) = me->event_producer_resolver->resolve( event_producer_class ).

        IF producer IS NOT BOUND.
          RETURN.
        ENDIF.

        producer->on_item_interpreted(
          ruleset               = ruleset_ref
          interpretation_itm    = interpretation_itm
          interpretation_result = interpretation_result
          context               = context ).

      CATCH cx_root.
        "event producer errors should not break interpretation
        RETURN.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.

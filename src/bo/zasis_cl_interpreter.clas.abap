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
        event_producer_resolver TYPE REF TO zasis_if_ev_producer_resolver OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA auth_checker TYPE REF TO zasis_if_auth_checker.
    DATA event_producer_resolver TYPE REF TO zasis_if_ev_producer_resolver.

    METHODS call_custom_logic
      IMPORTING
        custom_logic_class           TYPE zasis_customlogic
        ruleset_ref                  TYPE REF TO zasis_if_ruleset
        current_rule_item            TYPE zasis_rulesetitm
        string_to_be_interpreted     TYPE string
      RETURNING
        VALUE(interpretation_result) TYPE string
      RAISING
        zasis_cx_exc.

    METHODS call_event_producer
      IMPORTING
        event_producer_class  TYPE zasis_event_producer
        ruleset_ref           TYPE REF TO zasis_if_ruleset
        interpretation_itm    TYPE zasis_ruleset_item
        interpretation_result TYPE zasis_interpret_result_line.
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
                                                          string_to_be_interpreted = string_to_be_interpreted ).

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
                                   interpretation_result = <result_line> ).
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

    DATA(method) = 'EXECUTE'.
    DATA(class) = to_upper( custom_logic_class ).

    TRY.

        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = custom_logic_class
                                             RECEIVING  p_descr_ref    = DATA(type_descr)
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).

        IF sy-subrc NE 0 OR type_descr IS NOT BOUND.
          RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>error_custom_log_processing ).
        ENDIF.

        DATA(descr_ref) = CAST cl_abap_objectdescr( type_descr ).

        DATA(interfaces) = descr_ref->interfaces.

        IF NOT line_exists( interfaces[ name = zasis_constants=>ruleset_execution-custom_log_if_name ] ).

          RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>custom_logic_no_intf ).

        ENDIF.

        CALL METHOD (class)=>(method)
          EXPORTING
            string_to_be_interpretet = string_to_be_interpreted
            ruleset                  = ruleset_ref
            current_rule_item        = current_rule_item
          RECEIVING
            interpretation_result    = interpretation_result.

      CATCH cx_sy_dyn_call_illegal_class.

        RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>error_custom_log_processing ).

    ENDTRY.

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
          interpretation_result = interpretation_result ).

      CATCH cx_root.
        "event producer errors should not break interpretation
        RETURN.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.

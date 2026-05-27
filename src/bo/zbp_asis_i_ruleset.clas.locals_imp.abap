CLASS lhc_rulesetitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION."

    METHODS checkIsValidRegex FOR VALIDATE ON SAVE
      IMPORTING keys FOR RuleSetItem~checkIsValidRegex.
    METHODS checkEventProducer FOR VALIDATE ON SAVE
      IMPORTING keys FOR RuleSetItem~checkEventProducer.
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE RuleSetItem.

ENDCLASS.

CLASS lhc_rulesetitem IMPLEMENTATION.
  METHOD checkIsValidRegex.
    READ ENTITIES OF zasis_i_ruleset IN LOCAL MODE
         ENTITY RuleSetItem
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(rulesetitems).

    IF rulesetitems IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT rulesetitems INTO DATA(rulesetitem).
      TRY.
          DATA(regex) = cl_abap_regex=>create_pcre( pattern = rulesetitem-InterpretationRule ).

        CATCH cx_sy_regex cx_sy_invalid_regex_operation.

          APPEND VALUE #( %tky = rulesetitem-%tky ) TO failed-rulesetitem.

          APPEND VALUE #( %tky = rulesetitem-%tky
                          %msg = NEW zasis_cx_ruleset_ui( textid   = zasis_cx_ruleset_ui=>invalid_regex
                                                          severity = if_abap_behv_message=>severity-error
                                                          regex    = rulesetitem-InterpretationRule ) )
                 TO reported-rulesetitem.

      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD checkEventProducer.
    READ ENTITIES OF zasis_i_ruleset IN LOCAL MODE
         ENTITY RuleSetItem
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(rulesetitems).

    IF rulesetitems IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT rulesetitems INTO DATA(rulesetitem).

      IF rulesetitem-EventProducer IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          zasis_cl_class_validator=>check_implements(
            class_name     = CONV string( rulesetitem-EventProducer )
            interface_name = zasis_constants=>ruleset_execution-event_producer_if_name ).

        CATCH zasis_cx_exc INTO DATA(exc).
          APPEND VALUE #( %tky = rulesetitem-%tky ) TO failed-rulesetitem.

          DATA(textid) = COND #( WHEN exc->if_t100_message~t100key-msgno = zasis_cx_exc=>class_not_exist-msgno
                                 THEN zasis_cx_ruleset_ui=>event_producer_not_exist
                                 ELSE zasis_cx_ruleset_ui=>event_producer_no_intf ).

          APPEND VALUE #( %tky = rulesetitem-%tky
                          %msg = NEW zasis_cx_ruleset_ui( textid    = textid
                                                          severity  = if_abap_behv_message=>severity-error
                                                          classname = rulesetitem-EventProducer ) )
                 TO reported-rulesetitem.
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    LOOP AT entities INTO DATA(entity).

      IF entity-%control-InterpretationRule EQ '01' AND entity-%control-InterpretationRule IS NOT INITIAL. " was updated, not deleted.

        TRY.
            DATA(regex) = cl_abap_regex=>create_pcre( pattern = entity-InterpretationRule ).

          CATCH cx_sy_invalid_regex.

            " invalid regex
            APPEND VALUE #( %tky = entity-%tky ) TO failed-rulesetitem.

            APPEND VALUE #( %tky = entity-%tky
                            %msg = NEW zasis_cx_ruleset_ui( textid   = zasis_cx_ruleset_ui=>invalid_regex
                                                            severity = if_abap_behv_message=>severity-error
                                                            regex    = entity-InterpretationRule ) )
                   TO reported-rulesetitem.

        ENDTRY.

      ENDIF.

      IF entity-%control-CustomLogic EQ '01' OR entity-CustomLogic IS NOT INITIAL. " was updated or deleted.

        TRY.
            zasis_cl_class_validator=>check_implements(
              class_name     = CONV string( entity-CustomLogic )
              interface_name = zasis_constants=>ruleset_execution-custom_log_if_name ).

          CATCH zasis_cx_exc INTO DATA(cl_exc).

            APPEND VALUE #( %tky = entity-%tky ) TO failed-rulesetitem.

            DATA(cl_textid) = COND #( WHEN cl_exc->if_t100_message~t100key-msgno = zasis_cx_exc=>class_not_exist-msgno
                                      THEN zasis_cx_ruleset_ui=>custom_logic_not_exist
                                      ELSE zasis_cx_ruleset_ui=>custom_logic_no_intf ).

            APPEND VALUE #( %tky = entity-%tky
                            %msg = NEW zasis_cx_ruleset_ui( textid   = cl_textid
                                                            severity = if_abap_behv_message=>severity-error ) )
                   TO reported-rulesetitem.

            CONTINUE.

        ENDTRY.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZASIS_I_RULESET DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION."

    METHODS get_global_authorizations  FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ruleset RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ruleset RESULT result.
    METHODS checkuniquerulesetid FOR VALIDATE ON SAVE
      IMPORTING keys FOR ruleset~checkuniquerulesetid.
    METHODS testRuleSet FOR MODIFY
      IMPORTING keys FOR ACTION ruleset~testRuleSet.

ENDCLASS.

CLASS lhc_ZASIS_I_RULESET IMPLEMENTATION.
  METHOD get_global_authorizations.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.

      AUTHORITY-CHECK OBJECT 'ZASIS_GRL'
                      ID 'ZASIS_RULE' DUMMY
                      ID 'ACTVT'      FIELD '01'.

      result-%create = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).

      IF result-%create = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg = NEW zasis_cx_ruleset_ui( textid   = zasis_cx_ruleset_ui=>no_auth
                                                        severity = if_abap_behv_message=>severity-error
                                                        action   = |Create| ) )
               TO reported-ruleset.

      ENDIF.

    ENDIF.

    " Authorization check for update operations
    IF requested_authorizations-%update = if_abap_behv=>mk-on.

      AUTHORITY-CHECK OBJECT 'ZASIS_GRL'
                      ID 'ZASIS_RULE' DUMMY
                      ID 'ACTVT'      FIELD '02'.

      result-%update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).

      IF result-%update = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg = NEW zasis_cx_ruleset_ui( textid   = zasis_cx_ruleset_ui=>no_auth
                                                        severity = if_abap_behv_message=>severity-error
                                                        action   = 'Update' ) )
               TO reported-ruleset.

      ENDIF.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.

      AUTHORITY-CHECK OBJECT 'ZASIS_GRL'
                      ID 'ZASIS_RULE' DUMMY
                      ID 'ACTVT'      FIELD '06'.

      result-%delete = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).

      IF result-%delete = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg = NEW zasis_cx_ruleset_ui( textid   = zasis_cx_ruleset_ui=>no_auth
                                                        severity = if_abap_behv_message=>severity-error
                                                        action   = 'Delete' ) )
               TO reported-ruleset.

      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD checkUniqueRuleSetId.

    READ ENTITIES OF zasis_i_ruleset IN LOCAL MODE
         ENTITY RuleSet
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(rulesets).

    IF rulesets IS INITIAL.
      RETURN.
    ENDIF.

    " Single DB call to find any already-existing RuleSet IDs among the candidates
    SELECT rulesetid FROM zasis_rulesethd
      FOR ALL ENTRIES IN @rulesets
      WHERE rulesetid = @rulesets-RuleSetId
      INTO TABLE @DATA(existing_ids).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT existing_ids INTO DATA(existing).
      READ TABLE rulesets INTO DATA(ruleset)
        WITH KEY RuleSetId = existing-rulesetid.
      IF sy-subrc = 0.
        " already taken, throw error
        APPEND VALUE #( %tky = ruleset-%tky ) TO failed-ruleset.

        APPEND VALUE #( %tky = ruleset-%tky
                        %msg = NEW zasis_cx_ruleset_ui( textid    = zasis_cx_ruleset_ui=>duplicate_rulesetid
                                                        severity  = if_abap_behv_message=>severity-error
                                                        rulesetid = ruleset-RuleSetId ) )
               TO reported-ruleset.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD testRuleSet.

    LOOP AT keys INTO DATA(key_row).

      READ ENTITIES OF zasis_i_ruleset IN LOCAL MODE
           ENTITY RuleSet
           ALL FIELDS WITH VALUE #( ( %tky = key_row-%tky ) )
           RESULT DATA(rulesets).

      IF rulesets IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(ruleset) = rulesets[ 1 ].
      DATA(test_string) = key_row-%param-test_string.

      TRY.
          DATA(ruleset_ref) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid(
            ruleset_id = ruleset-RuleSetId ).

          DATA(interpreter) = NEW zasis_cl_interpreter( ).

          DATA(interpretation_result) = interpreter->execute(
            string_to_be_interpreted = test_string
            ruleset                  = ruleset_ref ).

          " Report results as multiple messages to trigger popup dialog
          IF interpretation_result-results IS INITIAL.
            APPEND VALUE #( %msg = new_message_with_text(
                              severity = if_abap_behv_message=>severity-information
                              text     = |No results for input string| ) )
                   TO reported-ruleset.
          ELSE.
            LOOP AT interpretation_result-results INTO DATA(res_line).
              DATA(msg_severity) = COND #( WHEN res_line-interpretationresult = 'no match'
                                           THEN if_abap_behv_message=>severity-information
                                           ELSE if_abap_behv_message=>severity-success ).
              APPEND VALUE #( %msg = new_message_with_text(
                                severity = msg_severity
                                text     = |{ res_line-targetfield } = { res_line-interpretationresult }| ) )
                     TO reported-ruleset.
            ENDLOOP.
          ENDIF.

        CATCH zasis_cx_exc INTO DATA(exc).

          APPEND VALUE #( %tky = ruleset-%tky
                          %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = exc->get_text( ) ) )
                 TO reported-ruleset.

        CATCH zasis_cx_no_auth INTO DATA(auth_exc).

          APPEND VALUE #( %tky = ruleset-%tky
                          %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text     = auth_exc->get_text( ) ) )
                 TO reported-ruleset.

      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

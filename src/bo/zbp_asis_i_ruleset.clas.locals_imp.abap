CLASS lhc_rulesetitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION."

    METHODS checkIsValidRegex FOR VALIDATE ON SAVE ##CALLED
      IMPORTING keys FOR RuleSetItem~checkIsValidRegex. ##CALLED
    METHODS checkEventProducer FOR VALIDATE ON SAVE
      IMPORTING keys FOR RuleSetItem~checkEventProducer. ##CALLED
    METHODS checkCustomLogic FOR VALIDATE ON SAVE
      IMPORTING keys FOR RuleSetItem~checkCustomLogic. ##CALLED
    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE RuleSetItem ##CALLED.

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
          DATA(regex) = cl_abap_regex=>create_pcre( pattern = rulesetitem-InterpretationRule ) ##NEEDED.

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

  METHOD checkCustomLogic.
    READ ENTITIES OF zasis_i_ruleset IN LOCAL MODE
         ENTITY RuleSetItem
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(rulesetitems).

    IF rulesetitems IS INITIAL.
      RETURN.
    ENDIF.

    " Bulk read catalog entries for all referenced custom logic classes
    " Note: SELECT from DB table intentionally bypasses DCL to see all entries
    " regardless of current user's display authorization for the catalog.
    SELECT class_name AS ClassName, status AS Status FROM zasis_custlogcat
      FOR ALL ENTRIES IN @rulesetitems
      WHERE class_name = @rulesetitems-CustomLogic
      INTO TABLE @DATA(catalog_entries).

    IF sy-subrc <> 0.
      CLEAR catalog_entries.
    ENDIF.

    LOOP AT rulesetitems INTO DATA(rulesetitem).

      IF rulesetitem-CustomLogic IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE catalog_entries INTO DATA(entry)
        WITH KEY ClassName = rulesetitem-CustomLogic.

      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = rulesetitem-%tky ) TO failed-rulesetitem.

        APPEND VALUE #( %tky = rulesetitem-%tky
                        %msg = NEW zasis_cx_ruleset_ui( textid    = zasis_cx_ruleset_ui=>custom_logic_not_exist
                                                        severity  = if_abap_behv_message=>severity-error
                                                        classname = rulesetitem-CustomLogic ) )
               TO reported-rulesetitem.
        CONTINUE.
      ENDIF.

      IF entry-Status <> zasis_constants=>enhcat_status-active.
        APPEND VALUE #( %tky = rulesetitem-%tky ) TO failed-rulesetitem.

        APPEND VALUE #( %tky = rulesetitem-%tky
                        %msg = NEW zasis_cx_ruleset_ui( textid    = zasis_cx_ruleset_ui=>custom_logic_not_active
                                                        severity  = if_abap_behv_message=>severity-error
                                                        classname = rulesetitem-CustomLogic ) )
               TO reported-rulesetitem.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
    LOOP AT entities INTO DATA(entity).

      IF entity-%control-InterpretationRule EQ '01' AND entity-%control-InterpretationRule IS NOT INITIAL. " was updated, not deleted.

        TRY.
            DATA(regex) = cl_abap_regex=>create_pcre( pattern = entity-InterpretationRule ) ##NEEDED.

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

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZASIS_I_RULESET DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION."

    METHODS get_global_authorizations  FOR GLOBAL AUTHORIZATION ##CALLED
      IMPORTING REQUEST requested_authorizations FOR ruleset RESULT result. ##CALLED
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ruleset RESULT result ##NEEDED. ##NEEDED
    METHODS checkuniquerulesetid FOR VALIDATE ON SAVE ##CALLED
      IMPORTING keys FOR ruleset~checkuniquerulesetid.
    METHODS testRuleSet FOR MODIFY ##CALLED
      IMPORTING keys FOR ACTION ruleset~testRuleSet.
    METHODS copyRuleSet FOR MODIFY
      IMPORTING keys FOR ACTION ruleset~copyRuleSet ##CALLED.

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

  METHOD copyRuleSet.

    DATA: rulesets_cba TYPE TABLE FOR CREATE zasis_i_ruleset\_Items,
          rulesets     TYPE TABLE FOR CREATE zasis_i_ruleset.

    " Guard: %cid must be filled for factory actions — without it, CREATE BY association
    " would fail silently for source instances that have child items
    ASSERT NOT line_exists( keys[ %cid = '' ] ).

    " Read source ruleset header data
    READ ENTITIES OF zasis_i_ruleset IN LOCAL MODE
         ENTITY RuleSet
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(source_rulesets).

    " Read source ruleset items via association
    READ ENTITIES OF zasis_i_ruleset IN LOCAL MODE
         ENTITY RuleSet BY \_Items
         ALL FIELDS WITH CORRESPONDING #( source_rulesets )
         RESULT DATA(source_items).

    LOOP AT keys INTO DATA(key).
      TRY.
          DATA(source) = source_rulesets[ KEY entity COMPONENTS RuleSetUUID = key-%tky-RuleSetUUID ].
        CATCH cx_sy_itab_line_not_found.
          APPEND VALUE #( %cid  = key-%cid
                          %tky  = key-%tky
                          %fail = VALUE #( cause = if_abap_behv=>cause-not_found ) )
                 TO failed-ruleset.
          CONTINUE.
      ENDTRY.

      " Prepare new RuleSet header
      APPEND VALUE #( %cid  = key-%cid
                      %data = VALUE #( RuleSetId = key-%param-new_ruleset_id ) )
             TO rulesets.

      " Prepare items for create-by-association
      APPEND VALUE #( %cid_ref = key-%cid ) TO rulesets_cba ASSIGNING FIELD-SYMBOL(<items_cba>).

      DATA(item_counter) = 0.
      LOOP AT source_items ASSIGNING FIELD-SYMBOL(<source_item>)
        USING KEY entity WHERE RuleSetUUID = source-RuleSetUUID.

        item_counter += 1.

        DATA(event_producer) = COND #( WHEN key-%param-copy_event_producer = abap_true
                                       THEN <source_item>-EventProducer
                                       ELSE '' ).

        DATA(custom_logic) = COND #( WHEN key-%param-copy_custom_logic = abap_true
                                     THEN <source_item>-CustomLogic
                                     ELSE '' ).

        APPEND VALUE #( %cid               = |{ key-%cid }_ITEM_{ item_counter }|
                        Intpretationtarget = <source_item>-Intpretationtarget
                        InterpretationRule = <source_item>-InterpretationRule
                        InterpretationType = <source_item>-InterpretationType
                        OffsetPre          = <source_item>-OffsetPre
                        OffsetPost         = <source_item>-OffsetPost
                        ReplacementString  = <source_item>-ReplacementString
                        CustomLogic        = custom_logic
                        EventProducer      = event_producer )
               TO <items_cba>-%target.

      ENDLOOP.

    ENDLOOP.

    " Execute create + create-by-association in local mode
    MODIFY ENTITIES OF zasis_i_ruleset IN LOCAL MODE
      ENTITY RuleSet
        CREATE FIELDS ( RuleSetId )
          WITH rulesets
        CREATE BY \_Items FIELDS ( Intpretationtarget InterpretationRule InterpretationType
                                   OffsetPre OffsetPost ReplacementString CustomLogic EventProducer )
          WITH rulesets_cba
      MAPPED DATA(mapped_create)
      FAILED DATA(failed_create)
      REPORTED DATA(reported_create).

    " Map factory result: only root instance
    mapped-ruleset = mapped_create-ruleset.

    " Forward any failures
    INSERT LINES OF failed_create-ruleset INTO TABLE failed-ruleset.
    INSERT LINES OF reported_create-ruleset INTO TABLE reported-ruleset.

  ENDMETHOD.

ENDCLASS.

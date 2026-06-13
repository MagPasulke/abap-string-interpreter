CLASS lhc_custlogcatalog DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION ##CALLED
      IMPORTING REQUEST requested_authorizations FOR CustLogCatalog RESULT result.
    METHODS checkclassimplementsinterface FOR VALIDATE ON SAVE ##CALLED
      IMPORTING keys FOR CustLogCatalog~checkClassImplementsInterface.
    METHODS precheck_delete FOR PRECHECK ##CALLED
      IMPORTING keys FOR DELETE CustLogCatalog.
ENDCLASS.

CLASS lhc_custlogcatalog IMPLEMENTATION.

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
               TO reported-custlogcatalog.
      ENDIF.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      AUTHORITY-CHECK OBJECT 'ZASIS_GRL'
        ID 'ZASIS_RULE' DUMMY
        ID 'ACTVT'      FIELD '02'.
      result-%update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized ).
      IF result-%update = if_abap_behv=>auth-unauthorized.
        APPEND VALUE #( %msg = NEW zasis_cx_ruleset_ui( textid   = zasis_cx_ruleset_ui=>no_auth
                                                        severity = if_abap_behv_message=>severity-error
                                                        action   = |Update| ) )
               TO reported-custlogcatalog.
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
                                                        action   = |Delete| ) )
               TO reported-custlogcatalog.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD checkclassimplementsinterface.
    READ ENTITIES OF zasis_i_custlogcatalog IN LOCAL MODE
         ENTITY CustLogCatalog
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(catalogs).

    IF catalogs IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT catalogs INTO DATA(catalog).
      IF catalog-ClassName IS INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          zasis_cl_class_validator=>check_implements(
            class_name     = CONV string( catalog-ClassName )
            interface_name = zasis_constants=>ruleset_execution-custom_log_if_name ).

        CATCH zasis_cx_exc INTO DATA(exc).
          APPEND VALUE #( %tky = catalog-%tky ) TO failed-custlogcatalog.

          DATA(textid) = COND #( WHEN exc->if_t100_message~t100key-msgno = zasis_cx_exc=>class_not_exist-msgno
                                 THEN zasis_cx_ruleset_ui=>custom_logic_not_exist
                                 ELSE zasis_cx_ruleset_ui=>custom_logic_no_intf ).

          APPEND VALUE #( %tky = catalog-%tky
                          %msg = NEW zasis_cx_ruleset_ui( textid    = textid
                                                          severity  = if_abap_behv_message=>severity-error
                                                          classname = catalog-ClassName ) )
                 TO reported-custlogcatalog.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
    " Precheck runs BEFORE delete reaches the buffer — block if referenced
    READ ENTITIES OF zasis_i_custlogcatalog IN LOCAL MODE
         ENTITY CustLogCatalog
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(catalogs).

    IF catalogs IS INITIAL.
      RETURN.
    ENDIF.

    " Single DB read for all class names to avoid SELECT in loop
    " Note: SELECT from DB table intentionally bypasses DCL to see all references
    " regardless of current user's authorization for RuleSetItems.
    SELECT custom_logic AS CustomLogic FROM zasis_rulesetitm
      FOR ALL ENTRIES IN @catalogs
      WHERE custom_logic = @catalogs-ClassName
      INTO TABLE @DATA(referenced).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    LOOP AT catalogs INTO DATA(catalog).
      IF line_exists( referenced[ CustomLogic = catalog-ClassName ] ).
        APPEND VALUE #( %tky = catalog-%tky ) TO failed-custlogcatalog.

        APPEND VALUE #( %tky = catalog-%tky
                        %msg = NEW zasis_cx_ruleset_ui( textid    = zasis_cx_ruleset_ui=>catalog_entry_in_use
                                                        severity  = if_abap_behv_message=>severity-error
                                                        classname = catalog-ClassName ) )
               TO reported-custlogcatalog.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

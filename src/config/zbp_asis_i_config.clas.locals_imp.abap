CLASS lhc_config DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION ##CALLED
      IMPORTING REQUEST requested_authorizations FOR Config RESULT result.
    METHODS checkconfigkey FOR VALIDATE ON SAVE ##CALLED
      IMPORTING keys FOR Config~checkConfigKey.
ENDCLASS.

CLASS lhc_config IMPLEMENTATION.

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
               TO reported-config.
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
               TO reported-config.
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
               TO reported-config.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD checkconfigkey.
    READ ENTITIES OF zasis_i_config IN LOCAL MODE
         ENTITY Config
         FIELDS ( ConfigKey ) WITH CORRESPONDING #( keys )
         RESULT DATA(configs).

    IF configs IS INITIAL.
      RETURN.
    ENDIF.

    CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZASIS_CONFIG_KEY' ) )->get_ddic_fixed_values(
      EXPORTING  p_langu       = sy-langu
      RECEIVING p_fixed_values = DATA(fixed_values)
      EXCEPTIONS not_found     = 1
                 no_ddic_type  = 2
                 OTHERS        = 3 ).
    IF sy-subrc <> 0.
      CLEAR fixed_values.
    ENDIF.

    LOOP AT configs INTO DATA(config).
      IF line_exists( fixed_values[ low = config-ConfigKey ] ).
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = config-%tky ) TO failed-config.

      APPEND VALUE #( %tky               = config-%tky
                      %element-ConfigKey = if_abap_behv=>mk-on
                      %msg               = NEW zasis_cx_ruleset_ui( textid    = zasis_cx_ruleset_ui=>invalid_config_key
                                                                    severity  = if_abap_behv_message=>severity-error
                                                                    configkey = config-ConfigKey ) )
             TO reported-config.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

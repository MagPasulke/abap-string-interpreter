CLASS zasis_cl_ev_producer_resolver DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zasis_if_ev_producer_resolver.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_ev_producer_resolver IMPLEMENTATION.

  METHOD zasis_if_ev_producer_resolver~resolve.

    DATA instance TYPE REF TO object.
    DATA(class) = to_upper( class_name ).

    TRY.
        cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = class
                                             RECEIVING  p_descr_ref    = DATA(type_descr)
                                             EXCEPTIONS type_not_found = 1
                                                        OTHERS         = 2 ).

        IF sy-subrc <> 0 OR type_descr IS NOT BOUND.
          RETURN.
        ENDIF.

        DATA(descr_ref) = CAST cl_abap_objectdescr( type_descr ).

        IF NOT line_exists( descr_ref->interfaces[ name = zasis_constants=>ruleset_execution-event_producer_if_name ] ).
          RETURN.
        ENDIF.

        CREATE OBJECT instance TYPE (class).
        result = CAST zasis_if_event_producer( instance ).

      CATCH cx_root.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

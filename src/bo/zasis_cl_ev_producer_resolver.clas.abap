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

    TRY.
        zasis_cl_class_validator=>check_implements(
          class_name     = CONV string( class_name )
          interface_name = zasis_constants=>ruleset_execution-event_producer_if_name ).

        CREATE OBJECT instance TYPE (class_name).
        result = CAST zasis_if_event_producer( instance ).

      CATCH zasis_cx_exc cx_sy_create_object_error.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

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

    TRY.
        result = CAST zasis_if_event_producer(
          zasis_cl_class_validator=>create_instance(
            class_name     = CONV string( class_name )
            interface_name = zasis_constants=>ruleset_execution-event_producer_if_name ) ).

      CATCH zasis_cx_exc.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

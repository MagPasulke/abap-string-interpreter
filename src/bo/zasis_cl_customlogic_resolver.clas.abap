CLASS zasis_cl_customlogic_resolver DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zasis_if_customlogic_resolver.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_customlogic_resolver IMPLEMENTATION.

  METHOD zasis_if_customlogic_resolver~resolve.

    result = CAST zasis_if_customlogic(
      zasis_cl_class_validator=>create_instance(
        class_name     = CONV string( class_name )
        interface_name = zasis_constants=>ruleset_execution-custom_log_if_name ) ).

  ENDMETHOD.

ENDCLASS.

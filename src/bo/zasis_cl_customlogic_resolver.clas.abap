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

    DATA instance TYPE REF TO object.

    zasis_cl_class_validator=>check_implements(
      class_name     = CONV string( class_name )
      interface_name = zasis_constants=>ruleset_execution-custom_log_if_name ).

    CREATE OBJECT instance TYPE (class_name).
    result = CAST zasis_if_customlogic( instance ).

  ENDMETHOD.

ENDCLASS.

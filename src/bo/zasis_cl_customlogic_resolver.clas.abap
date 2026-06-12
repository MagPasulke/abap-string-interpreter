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

    " Check catalog: class must be registered and active
    SELECT SINGLE status FROM zasis_custlogcat
      WHERE class_name = @class_name
      INTO @DATA(status).

    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zasis_cx_exc(
        textid    = zasis_cx_exc=>class_not_exist
        classname = class_name ).
    ENDIF.

    IF status <> 1. " 1 = active (zasis_enhcat_status)
      RAISE EXCEPTION NEW zasis_cx_exc(
        textid    = zasis_cx_exc=>error_custom_log_processing
        classname = class_name ).
    ENDIF.

    CREATE OBJECT instance TYPE (class_name).
    result = CAST zasis_if_customlogic( instance ).

  ENDMETHOD.

ENDCLASS.

CLASS zasis_cl_class_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS check_implements
      IMPORTING
        class_name     TYPE string
        interface_name TYPE string
      RAISING
        zasis_cx_exc.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_class_validator IMPLEMENTATION.

  METHOD check_implements.

    DATA(upper_class) = to_upper( class_name ).

    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = upper_class
                                         RECEIVING  p_descr_ref    = DATA(type_descr)
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).

    IF sy-subrc <> 0 OR type_descr IS NOT BOUND.
      RAISE EXCEPTION NEW zasis_cx_exc(
        textid    = zasis_cx_exc=>class_not_exist
        classname = CONV #( upper_class ) ).
    ENDIF.

    DATA(descr_ref) = CAST cl_abap_objectdescr( type_descr ).

    IF NOT line_exists( descr_ref->interfaces[ name = to_upper( interface_name ) ] ).
      RAISE EXCEPTION NEW zasis_cx_exc(
        textid    = zasis_cx_exc=>class_no_intf
        classname = CONV #( upper_class ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

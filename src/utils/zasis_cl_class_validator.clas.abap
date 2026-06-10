CLASS zasis_cl_class_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Verifies that an ABAP class exists and implements the specified interface; raises an exception otherwise.
    "! @parameter class_name     | Name of the ABAP class to check (case-insensitive, converted to upper case internally)
    "! @parameter interface_name | Fully qualified name of the interface the class must implement
    "! @raising   zasis_cx_exc | Raised with class_not_exist when the class is unknown, or class_no_intf when the interface is not implemented
    CLASS-METHODS check_implements
      IMPORTING
        class_name     TYPE string
        interface_name TYPE string
      RAISING
        zasis_cx_exc.

    "! Verifies that an ABAP class exists and implements the specified interface, then creates and returns an instance.
    "! @parameter class_name     | Name of the ABAP class to instantiate
    "! @parameter interface_name | Fully qualified name of the interface the class must implement
    "! @parameter result         | New instance of the class as a generic object reference
    "! @raising   zasis_cx_exc | Raised when the class does not exist or does not implement the interface
    CLASS-METHODS create_instance
      IMPORTING
        class_name     TYPE string
        interface_name TYPE string
      RETURNING
        VALUE(result)  TYPE REF TO object
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

  METHOD create_instance.
    check_implements(
      class_name     = class_name
      interface_name = interface_name ).
    CREATE OBJECT result TYPE (class_name).
  ENDMETHOD.

ENDCLASS.

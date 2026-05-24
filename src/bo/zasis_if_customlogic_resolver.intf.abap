INTERFACE zasis_if_customlogic_resolver
  PUBLIC.

  "! Resolves a custom logic class name to a ready-to-use instance of zasis_if_customlogic.
  "! @parameter class_name | Name of the ABAP class that implements zasis_if_customlogic
  "! @parameter result     | Instance of the resolved custom logic class
  "! @raising   zasis_cx_exc | Raised when the class does not exist or does not implement zasis_if_customlogic
  METHODS resolve
    IMPORTING
      class_name    TYPE zasis_customlogic
    RETURNING
      VALUE(result) TYPE REF TO zasis_if_customlogic
    RAISING
      zasis_cx_exc.

ENDINTERFACE.

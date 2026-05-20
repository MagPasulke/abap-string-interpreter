INTERFACE zasis_if_customlogic_resolver
  PUBLIC.

  METHODS resolve
    IMPORTING
      class_name    TYPE zasis_customlogic
    RETURNING
      VALUE(result) TYPE REF TO zasis_if_customlogic
    RAISING
      zasis_cx_exc.

ENDINTERFACE.

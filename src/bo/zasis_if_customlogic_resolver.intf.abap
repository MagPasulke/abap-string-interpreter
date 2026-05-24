INTERFACE zasis_if_customlogic_resolver
  PUBLIC.

  "! <p class="shortText">Resolves a custom logic class name to an executable instance.</p>
  METHODS resolve
    IMPORTING
      class_name    TYPE zasis_customlogic
    RETURNING
      VALUE(result) TYPE REF TO zasis_if_customlogic
    RAISING
      zasis_cx_exc.

ENDINTERFACE.

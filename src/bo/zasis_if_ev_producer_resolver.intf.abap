INTERFACE zasis_if_ev_producer_resolver
  PUBLIC .

  "! Resolves an event producer class name to a ready-to-use instance of zasis_if_event_producer.
  "! @parameter class_name | Name of the ABAP class that implements zasis_if_event_producer
  "! @parameter result     | Instance of the resolved event producer class; initial if the class cannot be resolved
  METHODS resolve
    IMPORTING
      class_name    TYPE zasis_event_producer
    RETURNING
      VALUE(result) TYPE REF TO zasis_if_event_producer.

ENDINTERFACE.

INTERFACE zasis_if_ev_producer_resolver
  PUBLIC .

  METHODS resolve
    IMPORTING
      class_name    TYPE zasis_event_producer
    RETURNING
      VALUE(result) TYPE REF TO zasis_if_event_producer.

ENDINTERFACE.

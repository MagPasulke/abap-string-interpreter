INTERFACE zasis_if_ev_producer_resolver
  PUBLIC .

  "! <p class="shortText">Resolves an event producer class name to an executable instance.</p>
  METHODS resolve
    IMPORTING
      class_name    TYPE zasis_event_producer
    RETURNING
      VALUE(result) TYPE REF TO zasis_if_event_producer.

ENDINTERFACE.

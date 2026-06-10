CLASS zasis_constants DEFINITION
  PUBLIC
  ABSTRACT
  FINAL
    .

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF ruleitem_type,
        match   TYPE zasis_ruleitem_type VALUE `1`,
        replace TYPE zasis_ruleitem_type VALUE `2`,
      END OF ruleitem_type.

    CONSTANTS:
      BEGIN OF http_method,
        get     TYPE string VALUE `GET`,
        post    TYPE string VALUE `POST`,
        put     TYPE string VALUE `PUT`,
        delete  TYPE string VALUE `DELETE`,
        options TYPE string VALUE `OPTIONS`,
      END OF http_method.

    CONSTANTS:
      BEGIN OF content_type,
        application_json TYPE string VALUE `application/json`,
      END OF content_type.

    CONSTANTS:
      BEGIN OF ruleset_execution,
        custom_log_if_name    TYPE string VALUE `ZASIS_IF_CUSTOMLOGIC`,
        event_producer_if_name TYPE string VALUE `ZASIS_IF_EVENT_PRODUCER`,
      END OF ruleset_execution.

    CONSTANTS:
      BEGIN OF activity,
        create  TYPE string VALUE `01`,
        change  TYPE string VALUE `02`,
        display TYPE string VALUE `03`,
        delete  TYPE string VALUE `06`,
        execute TYPE string VALUE `16`,
      END OF activity.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_constants IMPLEMENTATION.
ENDCLASS.

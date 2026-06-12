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

    "! Human-readable type identifiers for export JSON.
    "! We use hardcoded constants instead of domain fixed value descriptions
    "! because the export schema is a stable contract that must not change
    "! based on logon language. Domain descriptions are language-dependent
    "! and could be translated, which would break import compatibility.
    CONSTANTS:
      BEGIN OF export_type,
        match   TYPE c LENGTH 7 VALUE 'MATCH',
        replace TYPE c LENGTH 7 VALUE 'REPLACE',
      END OF export_type.

    CONSTANTS:
      BEGIN OF export,
        schema_version TYPE c LENGTH 5 VALUE '1.0',
        resource_path  TYPE string VALUE 'ruleSetExport',
      END OF export.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_constants IMPLEMENTATION.
ENDCLASS.

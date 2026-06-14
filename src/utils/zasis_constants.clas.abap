CLASS zasis_constants DEFINITION
  PUBLIC
  ABSTRACT
  FINAL
    .

  PUBLIC SECTION.
    CONSTANTS:
      "! Rule item type MATCH.
      BEGIN OF ruleitem_type,
        "! Regex MATCH rule — extracts a value from the input string.
        match   TYPE zasis_ruleitem_type VALUE `1`,
        "! REPLACE rule — transforms the input string via substitution.
        replace TYPE zasis_ruleitem_type VALUE `2`,
      END OF ruleitem_type.

    CONSTANTS:
      "! HTTP method identifiers used for request routing.
      BEGIN OF http_method,
        "! HTTP GET method.
        get     TYPE string VALUE `GET`,
        "! HTTP POST method.
        post    TYPE string VALUE `POST`,
        "! HTTP PUT method.
        put     TYPE string VALUE `PUT`,
        "! HTTP DELETE method.
        delete  TYPE string VALUE `DELETE`,
        "! HTTP OPTIONS method.
        options TYPE string VALUE `OPTIONS`,
      END OF http_method.

    CONSTANTS:
      "! Supported content type values for HTTP responses.
      BEGIN OF content_type,
        "! JSON content type header value.
        application_json TYPE string VALUE `application/json`,
      END OF content_type.

    CONSTANTS:
      "! Interface names used for custom logic and event producer resolution.
      BEGIN OF ruleset_execution,
        "! Fully qualified name of the custom logic interface.
        custom_log_if_name    TYPE string VALUE `ZASIS_IF_CUSTOMLOGIC`,
        "! Fully qualified name of the event producer interface.
        event_producer_if_name TYPE string VALUE `ZASIS_IF_EVENT_PRODUCER`,
      END OF ruleset_execution.

    CONSTANTS:
      "! Human-readable type identifiers for export JSON.
      "! Hardcoded to keep the export schema language-independent and stable.
      BEGIN OF export_type,
        "! Export type label for MATCH rules.
        match   TYPE c LENGTH 7 VALUE 'MATCH',
        "! Export type label for REPLACE rules.
        replace TYPE c LENGTH 7 VALUE 'REPLACE',
      END OF export_type.

    CONSTANTS:
      "! Enhancement catalog entry status values.
      BEGIN OF enhcat_status,
        "! Entry is active and available for use.
        active     TYPE c LENGTH 1 VALUE '1',
        "! Entry is deprecated and should no longer be used.
        deprecated TYPE c LENGTH 1 VALUE '2',
      END OF enhcat_status.

    CONSTANTS:
      "! Export schema identifiers for RuleSet JSON export format.
      BEGIN OF export,
        "! Version of the export schema.
        schema_version TYPE c LENGTH 5 VALUE '1.0',
        "! Root resource path used in the export payload.
        resource_path  TYPE string VALUE 'ruleSetExport',
      END OF export.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_constants IMPLEMENTATION.
ENDCLASS.

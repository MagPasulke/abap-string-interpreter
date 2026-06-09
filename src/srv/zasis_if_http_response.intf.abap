INTERFACE zasis_if_http_response
  PUBLIC.

  "! Sets the HTTP response status code and reason phrase
  METHODS set_status
    IMPORTING
      code   TYPE i
      reason TYPE string.

  "! Sets a response header field
  METHODS set_header_field
    IMPORTING
      name  TYPE string
      value TYPE string.

  "! Sets the response body text
  METHODS set_body_text
    IMPORTING
      text TYPE string.

ENDINTERFACE.

INTERFACE zasis_if_http_request
  PUBLIC.

  "! Returns the request path (without leading slash handling)
  METHODS get_path
    RETURNING
      VALUE(path) TYPE string.

  "! Returns the HTTP method (GET, POST, etc.)
  METHODS get_method
    RETURNING
      VALUE(method) TYPE string.

  "! Returns the value of the specified header field
  METHODS get_header_field
    IMPORTING
      name          TYPE string
    RETURNING
      VALUE(value) TYPE string.

  "! Returns the request body as text
  METHODS get_body_text
    RETURNING
      VALUE(text) TYPE string.

ENDINTERFACE.

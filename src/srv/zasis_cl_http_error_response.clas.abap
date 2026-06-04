CLASS zasis_cl_http_error_response DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_error,
             code    TYPE string,
             message TYPE string,
             status  TYPE string,
           END OF ty_error.
    TYPES: BEGIN OF ty_error_envelope,
             error TYPE ty_error,
           END OF ty_error_envelope.
    "! Creates an error response instance from an exception.
    "! @parameter exception   | Exception to extract error details from
    "! @parameter http_status | HTTP status code string to include in the error response
    "! @parameter result      | Error response instance populated with the exception details
    CLASS-METHODS from_exception
      IMPORTING exception     TYPE REF TO cx_root
                http_status   TYPE string
      RETURNING VALUE(result) TYPE REF TO zasis_cl_http_error_response.
    "! Serializes the error envelope to a JSON string.
    "! @parameter json | JSON representation of the error envelope
    METHODS to_json RETURNING VALUE(json) TYPE /ui2/cl_json=>json.
  PRIVATE SECTION.
    DATA _envelope TYPE ty_error_envelope.
ENDCLASS.

CLASS zasis_cl_http_error_response IMPLEMENTATION.
  METHOD from_exception.

    result = NEW #( ).
    result->_envelope-error-message = exception->get_text( ).
    result->_envelope-error-status  = http_status.

    DATA(t100_msg) = CAST if_t100_message( exception ).
    result->_envelope-error-code = |{ t100_msg->t100key-msgid }/{ t100_msg->t100key-msgno }|.

  ENDMETHOD.
  METHOD to_json.

    json = /ui2/cl_json=>serialize( data = _envelope ).

  ENDMETHOD.
ENDCLASS.

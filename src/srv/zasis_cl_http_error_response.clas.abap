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
    "! Builds the error code (T100 message class/number, e.g. ZASIS_MSGS/015) of an exception.
    "! @parameter exception | Exception implementing IF_T100_MESSAGE
    "! @parameter result    | Error code
    CLASS-METHODS code_of
      IMPORTING exception     TYPE REF TO cx_root
      RETURNING VALUE(result) TYPE string.
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

    result->_envelope-error-code = code_of( exception ).

  ENDMETHOD.
  METHOD code_of.

    DATA(t100_key) = CAST if_t100_message( exception )->t100key.
    result = |{ t100_key-msgid }/{ t100_key-msgno }|.

  ENDMETHOD.
  METHOD to_json.

    json = /ui2/cl_json=>serialize( data = _envelope ).

  ENDMETHOD.
ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

"! Cloud Request Adapter — wraps if_web_http_request into zasis_if_http_request
CLASS lcl_cld_request DEFINITION.
  PUBLIC SECTION.
    INTERFACES zasis_if_http_request.
    METHODS constructor IMPORTING request TYPE REF TO if_web_http_request.
  PRIVATE SECTION.
    DATA _request TYPE REF TO if_web_http_request.
ENDCLASS.

CLASS lcl_cld_request IMPLEMENTATION.
  METHOD constructor.
    _request = request.
  ENDMETHOD.

  METHOD zasis_if_http_request~get_path.
    TRY.
        path = _request->get_header_field( i_name = '~path' ).
      CATCH cx_web_message_error.
        path = ||.
    ENDTRY.
  ENDMETHOD.

  METHOD zasis_if_http_request~get_method.
    TRY.
        method = _request->get_method( ).
      CATCH cx_web_message_error.
        method = ||.
    ENDTRY.
  ENDMETHOD.

  METHOD zasis_if_http_request~get_header_field.
    TRY.
        value = _request->get_header_field( i_name = name ).
      CATCH cx_web_message_error.
        value = ||.
    ENDTRY.
  ENDMETHOD.

  METHOD zasis_if_http_request~get_body_text.
    TRY.
        text = _request->get_text( ).
      CATCH cx_web_message_error.
        text = ||.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

"! Cloud Response Adapter — wraps if_web_http_response into zasis_if_http_response
CLASS lcl_cld_response DEFINITION.
  PUBLIC SECTION.
    INTERFACES zasis_if_http_response.
    METHODS constructor IMPORTING response TYPE REF TO if_web_http_response.
  PRIVATE SECTION.
    DATA _response TYPE REF TO if_web_http_response.
ENDCLASS.

CLASS lcl_cld_response IMPLEMENTATION.
  METHOD constructor.
    _response = response.
  ENDMETHOD.

  METHOD zasis_if_http_response~set_status.
    _response->set_status( i_code   = code
                           i_reason = reason ).
  ENDMETHOD.

  METHOD zasis_if_http_response~set_header_field.
    _response->set_header_field( i_name  = name
                                 i_value = value ).
  ENDMETHOD.

  METHOD zasis_if_http_response~set_body_text.
    _response->set_text( i_text = text ).
  ENDMETHOD.
ENDCLASS.

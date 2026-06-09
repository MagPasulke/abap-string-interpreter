*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

"! SICF Request Adapter — wraps if_http_request into zasis_if_http_request
CLASS lcl_sicf_request DEFINITION.
  PUBLIC SECTION.
    INTERFACES zasis_if_http_request.
    METHODS constructor IMPORTING request TYPE REF TO if_http_request.
  PRIVATE SECTION.
    DATA _request TYPE REF TO if_http_request.
ENDCLASS.

CLASS lcl_sicf_request IMPLEMENTATION.
  METHOD constructor.
    _request = request.
  ENDMETHOD.

  METHOD zasis_if_http_request~get_path.
    path = _request->get_header_field( '~path_info' ).
  ENDMETHOD.

  METHOD zasis_if_http_request~get_method.
    method = _request->get_method( ).
  ENDMETHOD.

  METHOD zasis_if_http_request~get_header_field.
    value = _request->get_header_field( name ).
  ENDMETHOD.

  METHOD zasis_if_http_request~get_body_text.
    text = _request->get_cdata( ).
  ENDMETHOD.
ENDCLASS.

"! SICF Response Adapter — wraps if_http_response into zasis_if_http_response
CLASS lcl_sicf_response DEFINITION.
  PUBLIC SECTION.
    INTERFACES zasis_if_http_response.
    METHODS constructor IMPORTING response TYPE REF TO if_http_response.
  PRIVATE SECTION.
    DATA _response TYPE REF TO if_http_response.
ENDCLASS.

CLASS lcl_sicf_response IMPLEMENTATION.
  METHOD constructor.
    _response = response.
  ENDMETHOD.

  METHOD zasis_if_http_response~set_status.
    _response->set_status( code   = code
                           reason = reason ).
  ENDMETHOD.

  METHOD zasis_if_http_response~set_header_field.
    _response->set_header_field( name  = name
                                 value = value ).
  ENDMETHOD.

  METHOD zasis_if_http_response~set_body_text.
    _response->set_cdata( text ).
  ENDMETHOD.
ENDCLASS.

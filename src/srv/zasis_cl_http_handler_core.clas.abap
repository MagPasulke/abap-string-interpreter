CLASS zasis_cl_http_handler_core DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_request_body,
             string_to_be_interpreted TYPE string,
             context                  TYPE zasis_tt_interpret_context,
           END OF ty_request_body.

    "! Creates the core handler with injected request and response adapters
    METHODS constructor
      IMPORTING
        request  TYPE REF TO zasis_if_http_request
        response TYPE REF TO zasis_if_http_response.

    "! Dispatches the request, executes business logic, writes response or error
    METHODS handle_request.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA _request   TYPE REF TO zasis_if_http_request.
    DATA _response  TYPE REF TO zasis_if_http_response.
    DATA _validator TYPE REF TO zasis_cl_http_requ_validator.

    METHODS handle_post
      RETURNING
        VALUE(result) TYPE string
      RAISING
        zasis_cx_exc
        zasis_cx_no_auth.

    METHODS handle_get
      RETURNING
        VALUE(result) TYPE string
      RAISING
        zasis_cx_exc
        zasis_cx_no_auth.

ENDCLASS.



CLASS zasis_cl_http_handler_core IMPLEMENTATION.

  METHOD constructor.
    _request   = request.
    _response  = response.
    _validator = NEW zasis_cl_http_requ_validator( request = _request ).
  ENDMETHOD.

  METHOD handle_request.
    TRY.
        DATA(response_body) = ||.
        CASE _request->get_method( ).
          WHEN zasis_constants=>http_method-get.
            response_body = handle_get( ).

          WHEN zasis_constants=>http_method-post.
            response_body = handle_post( ).

          WHEN OTHERS.
            RAISE EXCEPTION NEW zasis_cx_exc( textid      = zasis_cx_exc=>method_not_supported
                                              method      = _request->get_method( )
                                              http_status = '405' ).
        ENDCASE.

        _response->set_header_field( name  = 'Content-Type'
                                     value = zasis_constants=>content_type-application_json ).
        _response->set_body_text( response_body ).

      CATCH zasis_cx_exc INTO DATA(service_exception).

        DATA(error_json) = zasis_cl_http_error_response=>from_exception(
          exception   = service_exception
          http_status = service_exception->http_status
        )->to_json( ).

        _response->set_status( code   = CONV #( service_exception->http_status )
                               reason = service_exception->get_text( ) ).
        _response->set_header_field( name  = 'Content-Type'
                                     value = zasis_constants=>content_type-application_json ).
        _response->set_body_text( error_json ).

      CATCH zasis_cx_no_auth INTO DATA(auth_exception).

        DATA(auth_error_json) = zasis_cl_http_error_response=>from_exception(
          exception   = auth_exception
          http_status = '403'
        )->to_json( ).

        _response->set_status( code   = 403
                               reason = 'Forbidden' ).
        _response->set_header_field( name  = 'Content-Type'
                                     value = zasis_constants=>content_type-application_json ).
        _response->set_body_text( auth_error_json ).

    ENDTRY.
  ENDMETHOD.

  METHOD handle_post.
    DATA request_body TYPE ty_request_body.

    DATA(ruleset_id) = _validator->extract_ruleset_id( ).

    _validator->validate_content_type( ).

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = _request->get_body_text( )
        assoc_arrays = abap_true
      CHANGING
        data         = request_body
    ).

    DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( ruleset_id ).

    DATA(interpret_output) = NEW zasis_cl_interpreter( )->execute(
      ruleset                  = ruleset
      string_to_be_interpreted = request_body-string_to_be_interpreted
      context                  = request_body-context ).

    result = /ui2/cl_json=>serialize( data = interpret_output ).
  ENDMETHOD.

  METHOD handle_get.
    DATA(ruleset_id) = _validator->extract_ruleset_id( ).

    DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( ruleset_id ).

    DATA(responsebody) = VALUE zasis_srvruleset(
      header = CORRESPONDING #( ruleset->header )
      items  = CORRESPONDING #( ruleset->items ) ).

    result = /ui2/cl_json=>serialize( data = responsebody ).
  ENDMETHOD.

ENDCLASS.

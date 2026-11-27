CLASS zasis_cl_http_handler_core DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_request_body,
             string_to_be_interpreted TYPE string,
             context                  TYPE zasis_tt_interpret_context,
           END OF ty_request_body.

    TYPES: BEGIN OF ty_bulk_request_item,
             id                       TYPE string,
             string_to_be_interpreted TYPE string,
             context                  TYPE zasis_tt_interpret_context,
           END OF ty_bulk_request_item,
           ty_bulk_request_items TYPE STANDARD TABLE OF ty_bulk_request_item WITH EMPTY KEY,
           BEGIN OF ty_bulk_request,
             items TYPE ty_bulk_request_items,
           END OF ty_bulk_request.

    TYPES: BEGIN OF ty_bulk_summary,
             total              TYPE i,
             ok                 TYPE i,
             failed             TYPE i,
             skippedonpreverror TYPE i,
           END OF ty_bulk_summary,
           BEGIN OF ty_bulk_response_item,
             id     TYPE string,
             status TYPE string,
             output TYPE zasis_interpret_output,
           END OF ty_bulk_response_item,
           ty_bulk_response_items TYPE STANDARD TABLE OF ty_bulk_response_item WITH EMPTY KEY,
           BEGIN OF ty_bulk_response,
             rulesetid TYPE zasis_ruleset_id,
             summary   TYPE ty_bulk_summary,
             items     TYPE ty_bulk_response_items,
           END OF ty_bulk_response.

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

    METHODS handle_bulk
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

    METHODS handle_export
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
            _validator->extract_ruleset_id( ).
            IF _validator->is_bulk = abap_true.
              RAISE EXCEPTION NEW zasis_cx_exc( textid      = zasis_cx_exc=>method_not_supported
                                                method      = _request->get_method( )
                                                http_status = '405' ).
            ENDIF.
            DATA(resource) = _validator->path_elements[ _validator->num_path_elements - 1 ].
            IF resource = zasis_constants=>export-resource_path.
              handle_export( ).
              RETURN.
            ENDIF.
            response_body = handle_get( ).

          WHEN zasis_constants=>http_method-post.
            _validator->extract_ruleset_id( ).
            IF _validator->is_bulk = abap_true.
              response_body = handle_bulk( ).
            ELSE.
              response_body = handle_post( ).
            ENDIF.

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

  METHOD handle_bulk.
    DATA request_body TYPE ty_bulk_request.

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
    DATA(interpreter) = NEW zasis_cl_interpreter( ).

    DATA(response_body) = VALUE ty_bulk_response( rulesetid = ruleset_id ).

    LOOP AT request_body-items INTO DATA(item).
      APPEND VALUE #( id     = item-id
                      status = zasis_constants=>bulk-item_status-ok
                      output = interpreter->execute( ruleset                  = ruleset
                                                     string_to_be_interpreted = item-string_to_be_interpreted
                                                     context                  = item-context ) )
             TO response_body-items.
      response_body-summary-ok = response_body-summary-ok + 1.
    ENDLOOP.

    response_body-summary-total = lines( request_body-items ).

    result = /ui2/cl_json=>serialize( data = response_body ).
  ENDMETHOD.

  METHOD handle_get.
    DATA(ruleset_id) = _validator->extract_ruleset_id( ).

    DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( ruleset_id ).

    DATA(responsebody) = VALUE zasis_srvruleset(
      header = CORRESPONDING #( ruleset->header )
      items  = CORRESPONDING #( ruleset->items ) ).

    result = /ui2/cl_json=>serialize( data = responsebody ).
  ENDMETHOD.

  METHOD handle_export.
    DATA(ruleset_id) = _validator->extract_ruleset_id( ).

    DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( ruleset_id ).

    DATA(export_data) = NEW zasis_cl_export_mapper( )->map( ruleset ).

    DATA(json) = /ui2/cl_json=>serialize( data = export_data ).

    DATA(filename) = |{ ruleset->header-rulesetid }.json|.

    _response->set_header_field( name  = 'Content-Type'
                                 value = zasis_constants=>content_type-application_json ).
    _response->set_header_field( name  = 'Content-Disposition'
                                 value = |attachment; filename="{ filename }"| ).
    _response->set_body_text( json ).
  ENDMETHOD.

ENDCLASS.

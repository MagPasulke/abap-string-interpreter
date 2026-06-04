CLASS zasis_cl_http_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_http_handler IMPLEMENTATION.
  METHOD if_http_extension~handle_request.
    DATA response_body TYPE /ui2/cl_json=>json.

    TRY.
        DATA(request_handler) = NEW zasis_lcl_http_handler( request  = server->request
                                                            response = server->response ).

        CASE server->request->get_method( ).

          WHEN zasis_constants=>http_method-get.

            response_body = request_handler->handle_get( ).

          WHEN zasis_constants=>http_method-post.

            response_body = request_handler->handle_post( ).

          WHEN OTHERS.

            RAISE EXCEPTION NEW zasis_cx_exc( textid      = zasis_cx_exc=>method_not_supported
                                              method      = server->request->get_method( )
                                              http_status = '405' ).

        ENDCASE.

        server->response->set_header_field( name  = 'Content-Type'
                                            value = zasis_constants=>content_type-application_json ).
        server->response->set_cdata( response_body ).

      CATCH zasis_cx_exc INTO DATA(service_exception).

        DATA(error_json) = zasis_cl_http_error_response=>from_exception(
          exception   = service_exception
          http_status = service_exception->http_status
        )->to_json( ).

        server->response->set_status( code   = CONV #( service_exception->http_status )
                                      reason = service_exception->get_text( ) ).
        server->response->set_header_field( name  = 'Content-Type'
                                            value = zasis_constants=>content_type-application_json ).
        server->response->set_cdata( error_json ).

      CATCH zasis_cx_no_auth INTO DATA(auth_exception).

        DATA(auth_error_json) = zasis_cl_http_error_response=>from_exception(
          exception   = auth_exception
          http_status = '403'
        )->to_json( ).

        server->response->set_status( code   = '403'
                                      reason = 'Forbidden' ).
        server->response->set_header_field( name  = 'Content-Type'
                                            value = zasis_constants=>content_type-application_json ).
        server->response->set_cdata( auth_error_json ).

    ENDTRY.
  ENDMETHOD.
ENDCLASS.

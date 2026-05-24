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
    DATA response_body     TYPE /ui2/cl_json=>json.
    DATA service_exception TYPE REF TO zasis_cx_exc.
    DATA auth_exception    TYPE REF TO zasis_cx_no_auth.

    TRY.
        DATA(request_handler) = NEW zasis_lcl_http_handler( request  = server->request
                                                            response = server->response ).

        CASE server->request->get_method( ).

          WHEN zasis_constants=>http_method-get.

            response_body = request_handler->handle_get( ).

            server->response->set_header_field( name  = 'Content-Type'
                                                value = zasis_constants=>content_type-application_json ).
            server->response->set_cdata( response_body ).

          WHEN zasis_constants=>http_method-post.

            TRY.

                response_body = request_handler->handle_post( ).

                server->response->set_header_field( name  = 'Content-Type'
                                                    value = zasis_constants=>content_type-application_json ).
                server->response->set_cdata( response_body ).

              CATCH zasis_cx_exc INTO service_exception.

                server->response->set_status( code   = '400'
                                              reason = service_exception->get_text( ) ).
                RETURN.

            ENDTRY.

          WHEN OTHERS. " not supported

            server->response->set_status( code   = '405'
                                          reason = |Method { server->request->get_method( ) } not supported. | ).
            RETURN.

        ENDCASE.

      CATCH zasis_cx_exc INTO service_exception.

        server->response->set_status( code   = '400'
                                      reason = service_exception->get_text( ) ).

      CATCH zasis_cx_no_auth INTO auth_exception.

        server->response->set_status( code          = '403'
                                      reason        = |Forbidden - Missing Authorization|
                                      detailed_info = auth_exception->get_text( ) ).

        RETURN.

    ENDTRY.
  ENDMETHOD.
ENDCLASS.

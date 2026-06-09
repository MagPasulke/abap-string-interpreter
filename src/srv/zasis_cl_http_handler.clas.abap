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
    DATA(req_adapter) = NEW lcl_sicf_request( server->request ).
    DATA(res_adapter) = NEW lcl_sicf_response( server->response ).

    NEW zasis_cl_http_handler_core( request  = req_adapter
                                    response = res_adapter )->handle_request( ).
  ENDMETHOD.
ENDCLASS.

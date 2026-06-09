CLASS zasis_cl_http_handler_cld DEFINITION
  PUBLIC
  CREATE PUBLIC .

PUBLIC SECTION.

  INTERFACES if_http_service_extension .
PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_http_handler_cld IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    DATA(req_adapter) = NEW lcl_cld_request( request ).
    DATA(res_adapter) = NEW lcl_cld_response( response ).

    NEW zasis_cl_http_handler_core( request  = req_adapter
                                    response = res_adapter )->handle_request( ).
  ENDMETHOD.
ENDCLASS.

CLASS zasis_cl_http_requ_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA path              TYPE string        READ-ONLY.
    DATA num_path_elements TYPE i             READ-ONLY.
    DATA path_elements     TYPE string_table  READ-ONLY.

    "! Creates a request validator from the adapter interface
    METHODS constructor
      IMPORTING
        request TYPE REF TO zasis_if_http_request.

    "! Validates the content-type header is application/json
    METHODS validate_content_type
      RAISING
        zasis_cx_exc.

    "! Validates the path structure and extracts the ruleset ID
    METHODS extract_ruleset_id
      RETURNING
        VALUE(ruleset_id) TYPE zasis_ruleset_id
      RAISING
        zasis_cx_exc.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA _request TYPE REF TO zasis_if_http_request.

    METHODS determine_path_elements.

    METHODS validate_path
      RAISING
        zasis_cx_exc.

ENDCLASS.



CLASS zasis_cl_http_requ_validator IMPLEMENTATION.

  METHOD constructor.
    _request = request.
    determine_path_elements( ).
  ENDMETHOD.

  METHOD determine_path_elements.
    path = _request->get_path( ).
    SHIFT path LEFT BY 1 PLACES.
    SPLIT path AT '/' INTO TABLE path_elements.
    num_path_elements = lines( path_elements ).
  ENDMETHOD.

  METHOD extract_ruleset_id.
    validate_path( ).

    TRY.
        ruleset_id = path_elements[ num_path_elements ].
      CATCH cx_sy_itab_line_not_found.
        RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                          route  = path ).
    ENDTRY.
  ENDMETHOD.

  METHOD validate_content_type.
    DATA(request_content_type) = _request->get_header_field( 'content-type' ).
    IF request_content_type <> zasis_constants=>content_type-application_json.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>content_not_json ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_path.
    IF strlen( path ) = 0.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path ).
    ENDIF.

    IF num_path_elements < 2.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path ).
    ENDIF.

    IF ( path_elements[ num_path_elements - 1 ] <> |ruleSetExecution| AND
         path_elements[ num_path_elements - 1 ] <> |ruleSet| ).
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path ).
    ENDIF.

    IF path_elements[ num_path_elements ] IS INITIAL.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

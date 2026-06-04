*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS zasis_lcl_http_requ_validator DEFINITION.

  PUBLIC SECTION.

    DATA _request TYPE REF TO if_http_request.
    DATA path     TYPE string                      READ-ONLY.
    DATA num_path_elements TYPE i READ-ONLY.
    DATA path_elements TYPE TABLE OF string READ-ONLY.

    METHODS constructor IMPORTING request TYPE REF TO if_http_request.

    METHODS validate_content_type
      RAISING
        zasis_cx_exc.

    METHODS validate_path
      RAISING
        zasis_cx_exc.

    METHODS extract_ruleset_id_from_requ RETURNING VALUE(ruleset_id) TYPE zasis_ruleset_id  RAISING zasis_cx_exc.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS determine_path_elements.


ENDCLASS.

CLASS zasis_lcl_http_requ_validator IMPLEMENTATION.
  METHOD constructor.

    _request = request.

    determine_path_elements( ).

  ENDMETHOD.

  METHOD extract_ruleset_id_from_requ.

    validate_path( ).

    TRY.

        ruleset_id = path_elements[ num_path_elements ].

      CATCH cx_sy_itab_line_not_found.

        RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                          route  = path
                                          ).

    ENDTRY.
  ENDMETHOD.

  METHOD determine_path_elements.

    path = _request->get_header_field( '~path_info' ).
    SHIFT path LEFT BY 1 PLACES.
    SPLIT path AT '/' INTO TABLE path_elements.
    num_path_elements  = lines( path_elements ).

  ENDMETHOD.

  METHOD validate_content_type.

    DATA(request_content_type) = _request->get_header_field( 'content-type' ).
    IF request_content_type <> zasis_constants=>content_type-application_json.

      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>content_not_json
                                        ).
    ENDIF.

  ENDMETHOD.

  METHOD validate_path.

    IF strlen( path ) = 0.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path
                                        ).
    ENDIF.

    IF num_path_elements < 2.

      "there is only two valid routes:
      "" POST ruleSetExecution/ruleSetID & GET ruleSet/ruleSetID
      """ => both of them contain at least 2 elements
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path
                                        ).

    ENDIF.

    IF ( path_elements[ num_path_elements - 1 ] <> |ruleSetExecution| AND path_elements[ num_path_elements - 1 ] <> |ruleSet| ).

      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path
                                        ).

    ENDIF.

    IF path_elements[ num_path_elements ] IS INITIAL.

      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path
                                        ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS zasis_lcl_http_handler DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_abap_body,
             string_to_be_interpreted TYPE string,
             context TYPE zasis_tt_interpret_context,
           END OF ty_abap_body.

    DATA: request_body TYPE ty_abap_body READ-ONLY.

    DATA ruleset_id TYPE zasis_ruleset_id READ-ONLY.

    DATA request  TYPE REF TO if_http_request  READ-ONLY.
    DATA response TYPE REF TO if_http_response READ-ONLY.

    METHODS constructor IMPORTING request  TYPE REF TO if_http_request
                                  response TYPE REF TO if_http_response
                        RAISING
                                  zasis_cx_exc.

    METHODS handle_post RETURNING VALUE(interpretation_result) TYPE /ui2/cl_json=>json
                        RAISING
                                  zasis_cx_exc
                                  zasis_cx_no_auth.

    METHODS handle_get RETURNING VALUE(get_result) TYPE /ui2/cl_json=>json
                       RAISING
                                 zasis_cx_exc
                                 zasis_cx_no_auth.

  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.

CLASS zasis_lcl_http_handler IMPLEMENTATION.

  METHOD handle_post.

    DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( ruleset_id ).

    DATA(interpret_output) = NEW zasis_cl_interpreter( )->execute( ruleset = ruleset
                                                                    string_to_be_interpreted = request_body-string_to_be_interpreted
                                                                    context = request_body-context ).

    /ui2/cl_json=>serialize(
      EXPORTING
        data             = interpret_output
      RECEIVING
        r_json           = interpretation_result
    ).

  ENDMETHOD.

  METHOD constructor.

    DATA(request_validator) = NEW zasis_lcl_http_requ_validator( request = request ).

    ruleset_id = request_validator->extract_ruleset_id_from_requ( ).

    IF request->get_method( ) EQ zasis_constants=>http_method-post.
      request_validator->validate_content_type( ).

      /ui2/cl_json=>deserialize(
        EXPORTING
          json             = CONV string( request->get_cdata( ) )
          assoc_arrays     = abap_true
        CHANGING
          data             = request_body
      ).
    ENDIF.

    me->response = response.

    me->request  = request.

  ENDMETHOD.

  METHOD handle_get.

    DATA(ruleset) = zasis_cl_ruleset_factory=>get_ruleset_by_rulesetid( ruleset_id ).

    DATA(responsebody) = VALUE zasis_srvruleset( header = CORRESPONDING #( ruleset->header ) items = CORRESPONDING #( ruleset->items ) ).

    get_result = /ui2/cl_json=>serialize( data = responsebody ).

  ENDMETHOD.

ENDCLASS.

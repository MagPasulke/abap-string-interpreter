CLASS zasis_cl_http_requ_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA path              TYPE string        READ-ONLY.
    DATA num_path_elements TYPE i             READ-ONLY.
    DATA path_elements     TYPE string_table  READ-ONLY.
    "! True if the last path element is the bulk sub-resource (it is removed from path_elements)
    DATA is_bulk           TYPE abap_bool     READ-ONLY.

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

    "! Validates the number of bulk items: at least one, at most zasis_constants=>bulk-max_items
    METHODS validate_bulk_item_count
      IMPORTING
        item_count TYPE i
      RAISING
        zasis_cx_exc.

    "! Validates bulk item ids (in input order): each id must be non-empty and unique.
    "! Raises for the first offending item.
    METHODS validate_bulk_item_ids
      IMPORTING
        item_ids TYPE string_table
      RAISING
        zasis_cx_exc.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA _request TYPE REF TO zasis_if_http_request.

    METHODS determine_path_elements
      RAISING
        zasis_cx_exc.

    METHODS validate_path
      RAISING
        zasis_cx_exc.

ENDCLASS.



CLASS zasis_cl_http_requ_validator IMPLEMENTATION.

  METHOD constructor.
    _request = request.
  ENDMETHOD.

  METHOD determine_path_elements.
    path = _request->get_path( ).
    SHIFT path LEFT BY 1 PLACES.
    SPLIT path AT '/' INTO TABLE path_elements.
    num_path_elements = lines( path_elements ).

    is_bulk = abap_false.
    IF num_path_elements > 2
       AND path_elements[ num_path_elements ] = zasis_constants=>bulk-resource_path
       AND path_elements[ num_path_elements - 2 ] = |ruleSetExecution|.
      is_bulk = abap_true.
      DELETE path_elements INDEX num_path_elements.
      num_path_elements = num_path_elements - 1.
    ENDIF.
  ENDMETHOD.

  METHOD extract_ruleset_id.
    determine_path_elements( ).
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

  METHOD validate_bulk_item_count.
    IF item_count = 0.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>bulk_items_empty ).
    ENDIF.

    IF item_count > zasis_constants=>bulk-max_items.
      RAISE EXCEPTION NEW zasis_cx_exc( textid    = zasis_cx_exc=>bulk_too_many_items
                                        max_items = zasis_constants=>bulk-max_items ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_bulk_item_ids.
    DATA seen_ids TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

    LOOP AT item_ids INTO DATA(item_id).
      DATA(position) = sy-tabix.
      IF item_id IS INITIAL.
        RAISE EXCEPTION NEW zasis_cx_exc( textid        = zasis_cx_exc=>bulk_item_id_missing
                                          item_position = position ).
      ENDIF.

      INSERT item_id INTO TABLE seen_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION NEW zasis_cx_exc( textid  = zasis_cx_exc=>bulk_item_id_duplicate
                                          item_id = item_id ).
      ENDIF.
    ENDLOOP.
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
         path_elements[ num_path_elements - 1 ] <> |ruleSet| AND
         path_elements[ num_path_elements - 1 ] <> |ruleSetExport| ).
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path ).
    ENDIF.

    IF path_elements[ num_path_elements ] IS INITIAL.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>invalid_api_route
                                        route  = path ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

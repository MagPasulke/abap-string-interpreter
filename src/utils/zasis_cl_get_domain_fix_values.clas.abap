CLASS zasis_cl_get_domain_fix_values DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS respond_empty
      IMPORTING
        io_response TYPE REF TO if_rap_query_response.

ENDCLASS.



CLASS zasis_cl_get_domain_fix_values IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA result TYPE TABLE OF zasis_i_domain_fix_values.
    DATA(top)              = io_request->get_paging( )->get_page_size( ).
    DATA(skip)             = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields) = io_request->get_requested_elements( ) ##NEEDED.
    DATA(sort_order)       = io_request->get_sort_elements( ) ##NEEDED.

    TRY.
        DATA(filter_sql)    = io_request->get_filter( )->get_as_sql_string( ).
        DATA(filter_ranges) = io_request->get_filter( )->get_as_ranges( ).

        READ TABLE filter_ranges WITH KEY name = 'DOMAIN_NAME'
               INTO DATA(domain_name_filter).

        IF sy-subrc <> 0.
          "domain name filter not provided — return empty result
          respond_empty( io_response ).
          EXIT.
        ENDIF.

        DATA(domain_name) = CONV sxco_ad_object_name( domain_name_filter-range[ 1 ]-low ).

        CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( domain_name ) )->get_ddic_fixed_values(
          EXPORTING
            p_langu        = sy-langu
          RECEIVING
            p_fixed_values = DATA(fixed_values)
          EXCEPTIONS
            not_found      = 1
            no_ddic_type   = 2
            OTHERS         = 3 ).

        IF sy-subrc > 0.
          "domain not found or not a DDIC type — return empty result
          respond_empty( io_response ).
          EXIT.
        ENDIF.

        LOOP AT fixed_values INTO DATA(fixed_value).
          APPEND VALUE zasis_i_domain_fix_values(
            domain_name = domain_name
            pos         = sy-tabix
            low         = fixed_value-low
            high        = fixed_value-high
            description = fixed_value-ddtext
          ) TO result.
        ENDLOOP.

        DATA(max_index) = 0.
        IF top IS NOT INITIAL.
          max_index = top + skip.
        ENDIF.

        SELECT domain_name pos low high description FROM @result AS data_source_fields
           WHERE (filter_sql)
           ORDER BY domain_name "supress abaplint finding
           INTO TABLE @result
           UP TO @max_index ROWS ##SUBRC_OK.

        IF skip IS NOT INITIAL.
          DELETE result TO skip.
        ENDIF.

        io_response->set_total_number_of_records( lines( result ) ).
        io_response->set_data( result ).

      CATCH cx_rap_query_response_set_twic.
        "response already set — ignore
      CATCH cx_rap_query_filter_no_range cx_sy_move_cast_error.
        respond_empty( io_response ).
    ENDTRY.

  ENDMETHOD.


  METHOD respond_empty.

    DATA empty TYPE TABLE OF zasis_i_domain_fix_values.
    TRY.
        io_response->set_total_number_of_records( 0 ).
        io_response->set_data( empty ).
      CATCH cx_rap_query_response_set_twic.
        "response already set — ignore
    ENDTRY.

  ENDMETHOD.
ENDCLASS.

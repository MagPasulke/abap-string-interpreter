CLASS zasis_cl_get_domain_fix_values DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zasis_cl_get_domain_fix_values IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA business_data TYPE TABLE OF zasis_i_domain_fix_values.
    DATA business_data_line TYPE zasis_i_domain_fix_values.
    DATA(top)     = io_request->get_paging( )->get_page_size( ).
    DATA(skip)    = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields)  = io_request->get_requested_elements( ).
    DATA(sort_order)    = io_request->get_sort_elements( ).

    DATA domain_name  TYPE sxco_ad_object_name.

    TRY.
        DATA(filter_condition_string) = io_request->get_filter( )->get_as_sql_string( ).
        DATA(filter_condition_ranges) = io_request->get_filter( )->get_as_ranges(  ).

        READ TABLE filter_condition_ranges WITH KEY name = 'DOMAIN_NAME'
               INTO DATA(filter_condition_domain_name).

        IF sy-subrc = 0.
          domain_name = filter_condition_domain_name-range[ 1 ]-low.
        ELSE.
          "domain name filter not provided — return empty result
          TRY.
              io_response->set_total_number_of_records( lines( business_data ) ).
              io_response->set_data( business_data ).
            CATCH cx_rap_query_response_set_twic.
              "response already set — ignore
          ENDTRY.
          EXIT.

        ENDIF.

        business_data_line-domain_name = domain_name.

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
          TRY.
              io_response->set_total_number_of_records( lines( business_data ) ).
              io_response->set_data( business_data ).
            CATCH cx_rap_query_response_set_twic.
              "response already set — ignore
          ENDTRY.
          EXIT.
        ENDIF.

        DATA(pos) = 0.
        LOOP AT fixed_values INTO DATA(fixed_value).
          pos += 1.
          business_data_line-pos = pos.
          business_data_line-low = fixed_value-low.
          business_data_line-high = fixed_value-high.
          business_data_line-description = fixed_value-ddtext.
          APPEND business_data_line TO business_data.
        ENDLOOP.

        IF top IS NOT INITIAL.
          DATA(max_index) = top + skip.
        ELSE.
          max_index = 0.
        ENDIF.

        SELECT * FROM @business_data AS data_source_fields
           WHERE (filter_condition_string)
           INTO TABLE @business_data
           UP TO @max_index ROWS.
        IF sy-subrc <> 0.
          CLEAR business_data.
        ENDIF.

        IF skip IS NOT INITIAL.
          DELETE business_data TO skip.
        ENDIF.

        io_response->set_total_number_of_records( lines( business_data ) ).
        io_response->set_data( business_data ).

      CATCH cx_rap_query_response_set_twic.
        "response already set — ignore
      CATCH cx_root INTO DATA(exception).
        DATA(exception_message) = cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ).

        DATA(exception_t100_key) = cl_message_helper=>get_latest_t100_exception( exception )->t100key.

    ENDTRY.

  ENDMETHOD.
ENDCLASS.

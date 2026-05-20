*"* use this source file for your ABAP unit test classes

CLASS ltcl_auth_checker_mock DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zasis_if_auth_checker.
    DATA deny_execute TYPE abap_bool.
ENDCLASS.

CLASS ltcl_auth_checker_mock IMPLEMENTATION.
  METHOD zasis_if_auth_checker~check_read.
  ENDMETHOD.
  METHOD zasis_if_auth_checker~check_execute.
    IF deny_execute = abap_true.
      RAISE EXCEPTION NEW zasis_cx_no_auth( ).
    ENDIF.
  ENDMETHOD.
  METHOD zasis_if_auth_checker~check_create.
  ENDMETHOD.
  METHOD zasis_if_auth_checker~check_change.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_event_producer_mock DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zasis_if_event_producer.
    DATA called TYPE abap_bool.
    DATA call_count TYPE i.
    DATA received_itm TYPE zasis_ruleset_item.
    DATA received_result TYPE zasis_interpret_result_line.
    DATA received_context TYPE zasis_tt_interpret_context.
    DATA raise_exception TYPE abap_bool.
ENDCLASS.

CLASS ltcl_event_producer_mock IMPLEMENTATION.
  METHOD zasis_if_event_producer~on_item_interpreted.
    IF raise_exception = abap_true.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>error_custom_log_processing ).
    ENDIF.
    called = abap_true.
    call_count = call_count + 1.
    received_itm = interpretation_itm.
    received_result = interpretation_result.
    received_context = context.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_ev_producer_resolver_mock DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zasis_if_ev_producer_resolver.
    DATA mock_producer TYPE REF TO ltcl_event_producer_mock.
    DATA received_class_name TYPE string.
ENDCLASS.

CLASS ltcl_ev_producer_resolver_mock IMPLEMENTATION.
  METHOD zasis_if_ev_producer_resolver~resolve.
    received_class_name = class_name.
    IF mock_producer IS BOUND.
      result = mock_producer.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_customlogic_mock DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zasis_if_customlogic.
    DATA called TYPE abap_bool.
    DATA received_string TYPE string.
    DATA received_context TYPE zasis_tt_interpret_context.
    DATA return_value TYPE string.
    DATA raise_exception TYPE abap_bool.
ENDCLASS.

CLASS ltcl_customlogic_mock IMPLEMENTATION.
  METHOD zasis_if_customlogic~execute.
    IF raise_exception = abap_true.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>error_custom_log_processing ).
    ENDIF.
    called = abap_true.
    received_string = string_to_be_interpretet.
    received_context = context.
    interpretation_result = return_value.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_customlogic_resolver_mock DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zasis_if_customlogic_resolver.
    DATA mock_instance TYPE REF TO ltcl_customlogic_mock.
    DATA raise_exception TYPE abap_bool.
    DATA received_class_name TYPE string.
ENDCLASS.

CLASS ltcl_customlogic_resolver_mock IMPLEMENTATION.
  METHOD zasis_if_customlogic_resolver~resolve.
    received_class_name = class_name.
    IF raise_exception = abap_true.
      RAISE EXCEPTION NEW zasis_cx_exc( textid = zasis_cx_exc=>class_not_exist ).
    ENDIF.
    IF mock_instance IS BOUND.
      result = mock_instance.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_zasis_cl_interpreter DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA auth_mock TYPE REF TO ltcl_auth_checker_mock.
    DATA ev_producer_mock TYPE REF TO ltcl_event_producer_mock.
    DATA ev_resolver_mock TYPE REF TO ltcl_ev_producer_resolver_mock.
    DATA cl_mock TYPE REF TO ltcl_customlogic_mock.
    DATA cl_resolver_mock TYPE REF TO ltcl_customlogic_resolver_mock.

    METHODS setup.
    METHODS:
      test_execute_success FOR TESTING,
      test_no_match FOR TESTING,
      test_auth_denied FOR TESTING,
      test_replace_type FOR TESTING,
      test_invalid_type_raises_exc FOR TESTING,
      test_multiple_items FOR TESTING,
      test_offset_post FOR TESTING,
      test_ev_producer_called FOR TESTING,
      test_ev_prod_not_on_no_match FOR TESTING,
      test_ev_prod_not_when_empty FOR TESTING,
      test_ev_prod_correct_params FOR TESTING,
      test_ev_prod_error_no_break FOR TESTING,
      test_ctx_forwarded_to_ev_prod FOR TESTING,
      test_customlogic_positive FOR TESTING,
      test_customlogic_not_found FOR TESTING,
      test_customlogic_ctx_forward FOR TESTING,
      test_no_ctx_ev_prod_empty FOR TESTING,
      test_ctx_multi_items_all_calls FOR TESTING,
      test_cl_with_ev_producer FOR TESTING,
      test_cl_ev_prod_err_no_break FOR TESTING,
      test_cl_correct_item_forwarded FOR TESTING,
      test_cl_empty_result_no_match FOR TESTING,
      test_replace_with_ev_producer FOR TESTING,
      test_mixed_item_types FOR TESTING,
      test_offset_pre_post_combined FOR TESTING,
      test_offset_zeroes_result FOR TESTING,
      test_replace_no_match_exp_nm FOR TESTING,
      test_cl_ev_prod_ctx_forwarded FOR TESTING,
      test_ev_prod_resolver_clsname FOR TESTING,
      test_cl_resolver_classname FOR TESTING.
ENDCLASS.

CLASS ltcl_zasis_cl_interpreter IMPLEMENTATION.

  METHOD setup.
    auth_mock = NEW #( ).
    ev_producer_mock = NEW #( ).
    ev_resolver_mock = NEW #( ).
    ev_resolver_mock->mock_producer = ev_producer_mock.
    cl_mock = NEW #( ).
    cl_resolver_mock = NEW #( ).
    cl_resolver_mock->mock_instance = cl_mock.
  ENDMETHOD.

  METHOD test_execute_success.
    " Given
    DATA: ruleset TYPE REF TO zasis_if_ruleset.

    ruleset = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest')
      items  = VALUE #( ( intpretationtarget = 'DeliveryNo' interpretationrule = '<B52H>([^<]*)' interpretation_type = 1 offset_pre = 6 offset_post = 0 ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-targetfield
      exp = |DeliveryNo|
    ).

    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-interpretationresult
      exp = |MyDeliveryNote|
    ).

  ENDMETHOD.

  METHOD test_no_match.
    " Given
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( intpretationtarget = 'MaterialNo' interpretationrule = '<A7X>([^<]*)' interpretation_type = 1 offset_pre = 5 offset_post = 0 ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When
    DATA result_nm TYPE zasis_tt_interpretationresult.
    TRY.
        result_nm = cut->execute(
          string_to_be_interpreted = |<Start><NO_KNOWN_TAG>SomeValue<End>|
          ruleset                  = ruleset
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_equals(
      act = result_nm[ 1 ]-interpretationresult
      exp = |no match|
    ).
  ENDMETHOD.

  METHOD test_auth_denied.
    " Given
    DATA: ruleset TYPE REF TO zasis_if_ruleset.

    ruleset = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest')
      items  = VALUE #( ( intpretationtarget = 'DeliveryNo' interpretationrule = '<B52H>([^<]*)' interpretation_type = 1 offset_pre = 6 offset_post = 0 ) )
    ).

    auth_mock->deny_execute = abap_true.
    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When / Then
    TRY.
        cut->execute(
          string_to_be_interpreted = |<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>|
          ruleset                  = ruleset
        ).
        cl_abap_unit_assert=>fail( msg = |Expected zasis_cx_no_auth| ).
      CATCH zasis_cx_no_auth.
        " expected
      CATCH zasis_cx_exc INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected zasis_cx_exc: { exc->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_replace_type.
    " Given - replace strips the identifier tag (first occurrence)
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( intpretationtarget = 'Cleaned' interpretationrule = '<TAG>' interpretation_type = 2
                           replacement_string = '' offset_pre = 0 offset_post = 0 ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When
    DATA result_rt TYPE zasis_tt_interpretationresult.
    TRY.
        result_rt = cut->execute(
          string_to_be_interpreted = |<TAG>Hello|
          ruleset                  = ruleset
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_equals(
      act = result_rt[ 1 ]-interpretationresult
      exp = |Hello|
    ).
  ENDMETHOD.

  METHOD test_invalid_type_raises_exc.
    " Given
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( intpretationtarget = 'Field' interpretationrule = '.*' interpretation_type = 9
                           offset_pre = 0 offset_post = 0 ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When / Then
    TRY.
        cut->execute(
          string_to_be_interpreted = |anything|
          ruleset                  = ruleset
        ).
        cl_abap_unit_assert=>fail( msg = |Expected zasis_cx_exc for invalid type| ).
      CATCH zasis_cx_exc.
        " expected
      CATCH zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected zasis_cx_no_auth: { exc->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_multiple_items.
    " Given
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #(
        ( intpretationtarget = 'MaterialNo' interpretationrule = '<A7X>([^<]*)' interpretation_type = 1 offset_pre = 5 offset_post = 0 )
        ( intpretationtarget = 'DeliveryNo' interpretationrule = '<B52H>([^<]*)' interpretation_type = 1 offset_pre = 6 offset_post = 0 )
      )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When
    DATA result_mi TYPE zasis_tt_interpretationresult.
    TRY.
        result_mi = cut->execute(
          string_to_be_interpreted = |<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>|
          ruleset                  = ruleset
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_equals( act = lines( result_mi ) exp = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = result_mi[ 1 ]-interpretationresult
      exp = |MyMaterialNumber|
    ).

    cl_abap_unit_assert=>assert_equals(
      act = result_mi[ 2 ]-interpretationresult
      exp = |MyDeliveryNote|
    ).
  ENDMETHOD.

  METHOD test_offset_post.
    " Given - match "<B52H>MyDeliveryNote<End>" then trim 5 from end (<End> = 5 chars)
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( intpretationtarget = 'Trimmed' interpretationrule = '<B52H>([^$]*)' interpretation_type = 1
                           offset_pre = 6 offset_post = 5 ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When
    DATA result_op TYPE zasis_tt_interpretationresult.
    TRY.
        result_op = cut->execute(
          string_to_be_interpreted = |<Start><B52H>MyDeliveryNote<End>|
          ruleset                  = ruleset
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_equals(
      act = result_op[ 1 ]-interpretationresult
      exp = |MyDeliveryNote|
    ).
  ENDMETHOD.

  METHOD test_ev_producer_called.
    " Given - item with event_producer filled, match succeeds
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretationrule = '<TAG>([^<]*)' interpretation_type = 1
                           offset_pre = 5 offset_post = 0 event_producer = 'SOME_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<TAG>Value1|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_true( act = ev_producer_mock->called ).
  ENDMETHOD.

  METHOD test_ev_prod_not_on_no_match.
    " Given - item with event_producer filled, but regex won't match
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretationrule = '<NOMATCH>([^<]*)' interpretation_type = 1
                           offset_pre = 0 offset_post = 0 event_producer = 'SOME_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<TAG>Value1|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_false( act = ev_producer_mock->called ).
  ENDMETHOD.

  METHOD test_ev_prod_not_when_empty.
    " Given - item with NO event_producer, match succeeds
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretationrule = '<TAG>([^<]*)' interpretation_type = 1
                           offset_pre = 5 offset_post = 0 event_producer = '' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<TAG>Value1|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_false( act = ev_producer_mock->called ).
  ENDMETHOD.

  METHOD test_ev_prod_correct_params.
    " Given
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 42 intpretationtarget = 'TargetX'
                           interpretationrule = '<B>([^<]*)' interpretation_type = 1
                           offset_pre = 3 offset_post = 0 event_producer = 'SOME_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<B>ResultValue|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_equals( act = ev_producer_mock->received_itm exp = CONV zasis_ruleset_item( 42 ) ).
    cl_abap_unit_assert=>assert_equals( act = ev_producer_mock->received_result-targetfield exp = 'TargetX' ).
    cl_abap_unit_assert=>assert_equals( act = ev_producer_mock->received_result-interpretationresult exp = |ResultValue| ).
  ENDMETHOD.

  METHOD test_ev_prod_error_no_break.
    " Given - event producer will raise an exception
    ev_producer_mock->raise_exception = abap_true.

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretationrule = '<TAG>([^<]*)' interpretation_type = 1
                           offset_pre = 5 offset_post = 0 event_producer = 'SOME_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When - should NOT raise, exception is swallowed
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<TAG>Value1|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - result is still produced despite event producer failure
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |Value1| ).
  ENDMETHOD.

  METHOD test_ctx_forwarded_to_ev_prod.
    " Given - context with multiple pairs, event producer item
    DATA(context) = VALUE zasis_tt_interpret_context(
      ( ctx_key = 'plant' value = '1000' )
      ( ctx_key = 'source' value = 'scanner_01' )
    ).

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretationrule = '<TAG>([^<]*)' interpretation_type = 1
                           offset_pre = 5 offset_post = 0 event_producer = 'SOME_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<TAG>Value1|
            ruleset                  = ruleset
            context                  = context
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - event producer received the full context
    cl_abap_unit_assert=>assert_equals( act = lines( ev_producer_mock->received_context ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ev_producer_mock->received_context[ 1 ]-value exp = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = ev_producer_mock->received_context[ 2 ]-value exp = 'scanner_01' ).
  ENDMETHOD.

  METHOD test_customlogic_positive.
    " Given - custom logic resolver returns mock that produces a result
    cl_mock->return_value = |CustomResult|.

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretationrule = '<TAG>([^<]*)' interpretation_type = 1
                           offset_pre = 5 offset_post = 0
                           custom_logic = 'ZCL_MY_CUSTOM_LOGIC' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker         = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver = cl_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<TAG>Value1|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result_cl)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then
    cl_abap_unit_assert=>assert_true( act = cl_mock->called ).
    cl_abap_unit_assert=>assert_equals( act = result_cl[ 1 ]-interpretationresult exp = |CustomResult| ).
    cl_abap_unit_assert=>assert_equals( act = result_cl[ 1 ]-targetfield exp = |Field1| ).
  ENDMETHOD.

  METHOD test_customlogic_not_found.
    " Given - resolver raises exception (class not found)
    cl_resolver_mock->raise_exception = abap_true.

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretationrule = '<TAG>([^<]*)' interpretation_type = 1
                           offset_pre = 5 offset_post = 0
                           custom_logic = 'ZCL_NONEXISTENT_LOGIC' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker         = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver = cl_resolver_mock ).

    " When / Then - should raise zasis_cx_exc
    TRY.
        cut->execute(
          string_to_be_interpreted = |<TAG>Value1|
          ruleset                  = ruleset
        ).
        cl_abap_unit_assert=>fail( msg = |Expected zasis_cx_exc for missing custom logic class| ).
      CATCH zasis_cx_exc.
        " expected
      CATCH zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected zasis_cx_no_auth: { exc->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

  METHOD test_customlogic_ctx_forward.
    " Given - context is forwarded to custom logic
    cl_mock->return_value = |CtxResult|.

    DATA(context) = VALUE zasis_tt_interpret_context(
      ( ctx_key = 'warehouse' value = 'WH01' )
    ).

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretationrule = '<TAG>([^<]*)' interpretation_type = 1
                           offset_pre = 5 offset_post = 0
                           custom_logic = 'ZCL_MY_CUSTOM_LOGIC' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker         = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver = cl_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<TAG>Value1|
            ruleset                  = ruleset
            context                  = context
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - custom logic received context
    cl_abap_unit_assert=>assert_equals( act = lines( cl_mock->received_context ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = cl_mock->received_context[ 1 ]-value exp = 'WH01' ).
    " And received the input string
    cl_abap_unit_assert=>assert_equals( act = cl_mock->received_string exp = |<TAG>Value1| ).
  ENDMETHOD.

  METHOD test_no_ctx_ev_prod_empty.
    " Given - NO context passed, event producer item
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretationrule = '<TAG>([^<]*)' interpretation_type = 1
                           offset_pre = 5 offset_post = 0 event_producer = 'SOME_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When - no context parameter passed
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<TAG>Value1|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - event producer receives empty context table
    cl_abap_unit_assert=>assert_true( act = ev_producer_mock->called ).
    cl_abap_unit_assert=>assert_equals( act = lines( ev_producer_mock->received_context ) exp = 0 ).
  ENDMETHOD.

  METHOD test_ctx_multi_items_all_calls.
    " Given - context + multiple items with event_producer
    DATA(context) = VALUE zasis_tt_interpret_context(
      ( ctx_key = 'batch' value = 'B001' )
    ).

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #(
        ( interpretationitm = 1 intpretationtarget = 'Field1'
          interpretationrule = '<A>([^<]*)' interpretation_type = 1
          offset_pre = 3 offset_post = 0 event_producer = 'SOME_CLASS' )
        ( interpretationitm = 2 intpretationtarget = 'Field2'
          interpretationrule = '<B>([^<]*)' interpretation_type = 1
          offset_pre = 3 offset_post = 0 event_producer = 'SOME_CLASS' )
      )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<A>Val1<B>Val2|
            ruleset                  = ruleset
            context                  = context
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - event producer called twice, last call has context
    cl_abap_unit_assert=>assert_equals( act = ev_producer_mock->call_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ev_producer_mock->received_context ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ev_producer_mock->received_context[ 1 ]-value exp = 'B001' ).
  ENDMETHOD.

  METHOD test_cl_with_ev_producer.
    " Given - item has both custom_logic and event_producer set
    cl_mock->return_value = |CustomOutput|.

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretation_type = 1 offset_pre = 0 offset_post = 0
                           custom_logic = 'ZCL_MY_CUSTOM_LOGIC'
                           event_producer = 'SOME_PRODUCER_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker            = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver    = cl_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |InputString|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - custom logic result used AND event producer fired with that result
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |CustomOutput| ).
    cl_abap_unit_assert=>assert_true( act = ev_producer_mock->called ).
    cl_abap_unit_assert=>assert_equals(
      act = ev_producer_mock->received_result-interpretationresult
      exp = |CustomOutput|
    ).
  ENDMETHOD.

  METHOD test_cl_ev_prod_err_no_break.
    " Given - custom logic succeeds, event producer raises — must be swallowed
    cl_mock->return_value = |CustomOutput|.
    ev_producer_mock->raise_exception = abap_true.

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretation_type = 1 offset_pre = 0 offset_post = 0
                           custom_logic = 'ZCL_MY_CUSTOM_LOGIC'
                           event_producer = 'SOME_PRODUCER_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker            = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver    = cl_resolver_mock ).

    " When - must NOT raise
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |InputString|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - result still produced despite producer failure
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |CustomOutput| ).
  ENDMETHOD.

  METHOD test_cl_correct_item_forwarded.
    " Given - two items, custom logic on second item only (item 1 = MATCH type)
    " Verifies custom logic called for correct item and receives full input string
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #(
        ( interpretationitm = 1 intpretationtarget = 'Field1'
          interpretationrule = '<A>([^<]*)' interpretation_type = 1
          offset_pre = 3 offset_post = 0 )
        ( interpretationitm = 2 intpretationtarget = 'Field2'
          interpretation_type = 1 offset_pre = 0 offset_post = 0
          custom_logic = 'ZCL_MY_CUSTOM_LOGIC' )
      )
    ).

    cl_mock->return_value = |CustomForItem2|.

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker            = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver    = cl_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<A>Val1|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - custom logic called once (only item 2), item 1 matched via regex
    cl_abap_unit_assert=>assert_true( act = cl_mock->called ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |Val1| ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-interpretationresult exp = |CustomForItem2| ).
    " Custom logic received the full input string
    cl_abap_unit_assert=>assert_equals( act = cl_mock->received_string exp = |<A>Val1| ).
  ENDMETHOD.

  METHOD test_cl_empty_result_no_match.
    " Given - custom logic returns empty string
    cl_mock->return_value = ||.

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretation_type = 1 offset_pre = 0 offset_post = 0
                           custom_logic = 'ZCL_MY_CUSTOM_LOGIC'
                           event_producer = 'SOME_PRODUCER_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker            = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver    = cl_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |InputString|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - empty return treated as no match, producer NOT called
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |no match| ).
    cl_abap_unit_assert=>assert_false( act = ev_producer_mock->called ).
  ENDMETHOD.

  METHOD test_replace_with_ev_producer.
    " Given - REPLACE item with event_producer set, regex matches
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 5 intpretationtarget = 'Cleaned'
                           interpretationrule = '<TAG>' interpretation_type = 2
                           replacement_string = '' offset_pre = 0 offset_post = 0
                           event_producer = 'REPLACE_PRODUCER' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker            = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<TAG>Hello|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - REPLACE result is correct AND producer fired with that result
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |Hello| ).
    cl_abap_unit_assert=>assert_true( act = ev_producer_mock->called ).
    cl_abap_unit_assert=>assert_equals(
      act = ev_producer_mock->received_result-interpretationresult
      exp = |Hello|
    ).
  ENDMETHOD.

  METHOD test_mixed_item_types.
    " Given - three items: MATCH, REPLACE, custom logic
    cl_mock->return_value = |CustomValue|.

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #(
        ( interpretationitm = 1 intpretationtarget = 'MatchField'
          interpretationrule = '<A>([^<]*)' interpretation_type = 1
          offset_pre = 3 offset_post = 0 )
        ( interpretationitm = 2 intpretationtarget = 'ReplaceField'
          interpretationrule = '<TAG>' interpretation_type = 2
          replacement_string = '' offset_pre = 0 offset_post = 0 )
        ( interpretationitm = 3 intpretationtarget = 'CustomField'
          interpretation_type = 1 offset_pre = 0 offset_post = 0
          custom_logic = 'ZCL_MY_CUSTOM_LOGIC' )
      )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker            = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver    = cl_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<A>Val1<TAG>RestOfString|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - all three results present and correct
    cl_abap_unit_assert=>assert_equals( act = lines( result ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |Val1| ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-interpretationresult exp = |<A>Val1RestOfString| ).
    cl_abap_unit_assert=>assert_equals( act = result[ 3 ]-interpretationresult exp = |CustomValue| ).
  ENDMETHOD.

  METHOD test_offset_pre_post_combined.
    " Given - match "<B52H>MyDeliveryNote<End>", offset_pre=6, offset_post=5
    " Full match = "<B52H>MyDeliveryNote<End>" (25 chars)
    " After offset_pre=6: "MyDeliveryNote<End>" (19 chars)
    " After offset_post=5: "MyDeliveryNote" (14 chars)
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( intpretationtarget = 'Both' interpretationrule = '<B52H>[^$]*' interpretation_type = 1
                           offset_pre = 6 offset_post = 5 ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<Start><B52H>MyDeliveryNote<End>|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - both offsets applied correctly
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |MyDeliveryNote| ).
  ENDMETHOD.

  METHOD test_offset_zeroes_result.
    " Given - match "AB" (2 chars), offset_pre=1, offset_post=1 → length = 0 → no match
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( intpretationtarget = 'Zero' interpretationrule = 'AB' interpretation_type = 1
                           offset_pre = 1 offset_post = 1 ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |AB|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - zero-length result after offsets → no match
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |no match| ).
  ENDMETHOD.

  METHOD test_replace_no_match_exp_nm.
    " Given - REPLACE with regex that does NOT match input
    " ABAP replace() returns original string when no match — current behavior produces a result
    " This test documents the EXPECTED behavior: no match → "no match" entry
    " TODO: This test INTENTIONALLY FAILS — known bug tracked in issue #21.
    "       Do NOT fix here. Fix lands when issue #21 is resolved and this test will then pass.
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( intpretationtarget = 'Cleaned'
                           interpretationrule = '<NOTPRESENT>' interpretation_type = 2
                           replacement_string = '' offset_pre = 0 offset_post = 0 ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker = auth_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |HelloWorld|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - REPLACE with no match should produce "no match" (currently fails — bug to fix separately)
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |no match| ).
  ENDMETHOD.

  METHOD test_cl_ev_prod_ctx_forwarded.
    " Given - item with custom_logic + event_producer, context provided
    " Verify context flows to both custom logic AND event producer
    cl_mock->return_value = |CtxChainResult|.

    DATA(context) = VALUE zasis_tt_interpret_context(
      ( ctx_key = 'plant' value = '2000' )
      ( ctx_key = 'user'  value = 'TESTUSER' )
    ).

    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #( ( interpretationitm = 1 intpretationtarget = 'Field1'
                           interpretation_type = 1 offset_pre = 0 offset_post = 0
                           custom_logic = 'ZCL_MY_CUSTOM_LOGIC'
                           event_producer = 'SOME_PRODUCER_CLASS' ) )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker            = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver    = cl_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |InputString|
            ruleset                  = ruleset
            context                  = context
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - custom logic received context
    cl_abap_unit_assert=>assert_equals( act = lines( cl_mock->received_context ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = cl_mock->received_context[ 1 ]-value exp = '2000' ).
    " And event producer received same context
    cl_abap_unit_assert=>assert_equals( act = lines( ev_producer_mock->received_context ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ev_producer_mock->received_context[ 2 ]-value exp = 'TESTUSER' ).
  ENDMETHOD.

  METHOD test_ev_prod_resolver_clsname.
    " Given - two items with different event_producer class names
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #(
        ( interpretationitm = 1 intpretationtarget = 'Field1'
          interpretationrule = '<A>([^<]*)' interpretation_type = 1
          offset_pre = 3 offset_post = 0 event_producer = 'ZCL_PRODUCER_A' )
        ( interpretationitm = 2 intpretationtarget = 'Field2'
          interpretationrule = '<B>([^<]*)' interpretation_type = 1
          offset_pre = 3 offset_post = 0 event_producer = 'ZCL_PRODUCER_B' )
      )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker            = auth_mock
                                           event_producer_resolver = ev_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |<A>Val1<B>Val2|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - resolver last received class name from item 2 (ZCL_PRODUCER_B)
    " Both items matched so resolver called twice; last call = item 2
    cl_abap_unit_assert=>assert_equals( act = ev_producer_mock->call_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ev_resolver_mock->received_class_name exp = |ZCL_PRODUCER_B| ).
  ENDMETHOD.

  METHOD test_cl_resolver_classname.
    " Given - two items with different custom_logic class names
    " Resolver mock captures last received class name; verify correct name forwarded per item
    cl_mock->return_value = |ResultA|.

    " Single mock_instance: both items resolve to same mock (sufficient to verify class name routing)
    DATA(ruleset) = NEW zasis_cl_ruleset(
      header = VALUE #( rulesetuuid = '9808AFDDDA' rulesetid = 'UnitTest' )
      items  = VALUE #(
        ( interpretationitm = 1 intpretationtarget = 'Field1'
          interpretation_type = 1 offset_pre = 0 offset_post = 0
          custom_logic = 'ZCL_LOGIC_ALPHA' )
        ( interpretationitm = 2 intpretationtarget = 'Field2'
          interpretation_type = 1 offset_pre = 0 offset_post = 0
          custom_logic = 'ZCL_LOGIC_BETA' )
      )
    ).

    DATA(cut) = NEW zasis_cl_interpreter( auth_checker            = auth_mock
                                           event_producer_resolver = ev_resolver_mock
                                           customlogic_resolver    = cl_resolver_mock ).

    " When
    TRY.
        cut->execute(
          EXPORTING
            string_to_be_interpreted = |InputString|
            ruleset                  = ruleset
          RECEIVING
            interpretation_result    = DATA(result)
        ).
      CATCH zasis_cx_exc zasis_cx_no_auth INTO DATA(exc).
        cl_abap_unit_assert=>fail( msg = |Unexpected exception: { exc->get_text( ) }| ).
    ENDTRY.

    " Then - resolver last received class name from item 2 (ZCL_LOGIC_BETA)
    cl_abap_unit_assert=>assert_equals( act = cl_resolver_mock->received_class_name exp = |ZCL_LOGIC_BETA| ).
  ENDMETHOD.

ENDCLASS.

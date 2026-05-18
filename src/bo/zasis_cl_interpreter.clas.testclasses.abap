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
    DATA received_itm TYPE zasis_ruleset_item.
    DATA received_result TYPE zasis_interpret_result_line.
    DATA raise_exception TYPE abap_bool.
ENDCLASS.

CLASS ltcl_event_producer_mock IMPLEMENTATION.
  METHOD zasis_if_event_producer~on_item_interpreted.
    IF raise_exception = abap_true.
      RAISE EXCEPTION TYPE cx_sy_zerodivide.
    ENDIF.
    called = abap_true.
    received_itm = interpretation_itm.
    received_result = interpretation_result.
  ENDMETHOD.
ENDCLASS.


CLASS ltcl_ev_producer_resolver_mock DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zasis_if_ev_producer_resolver.
    " Always returns mock_producer regardless of class_name.
    " The class_name in ruleset items (e.g. 'SOME_CLASS') just needs to be
    " non-empty to trigger the event producer call — it is never actually resolved.
    DATA mock_producer TYPE REF TO ltcl_event_producer_mock.
ENDCLASS.

CLASS ltcl_ev_producer_resolver_mock IMPLEMENTATION.
  METHOD zasis_if_ev_producer_resolver~resolve.
    " Ignores class_name — always returns the injected mock producer
    IF mock_producer IS BOUND.
      result = mock_producer.
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
      test_ev_prod_error_no_break FOR TESTING.
ENDCLASS.

CLASS ltcl_zasis_cl_interpreter IMPLEMENTATION.

  METHOD setup.
    auth_mock = NEW #( ).
    ev_producer_mock = NEW #( ).
    ev_resolver_mock = NEW #( ).
    ev_resolver_mock->mock_producer = ev_producer_mock.
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
    cut->execute(
      EXPORTING
        string_to_be_interpreted = |<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>|
        ruleset                  = ruleset
      RECEIVING
        interpretation_result    = DATA(result)
    ).

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
    DATA(result) = cut->execute(
      string_to_be_interpreted = |<Start><NO_KNOWN_TAG>SomeValue<End>|
      ruleset                  = ruleset
    ).

    " Then
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-interpretationresult
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
    DATA(result) = cut->execute(
      string_to_be_interpreted = |<TAG>Hello|
      ruleset                  = ruleset
    ).

    " Then
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-interpretationresult
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
    DATA(result) = cut->execute(
      string_to_be_interpreted = |<Start><A7X>MyMaterialNumber<B52H>MyDeliveryNote<End>|
      ruleset                  = ruleset
    ).

    " Then
    cl_abap_unit_assert=>assert_equals( act = lines( result ) exp = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-interpretationresult
      exp = |MyMaterialNumber|
    ).

    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-interpretationresult
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
    DATA(result) = cut->execute(
      string_to_be_interpreted = |<Start><B52H>MyDeliveryNote<End>|
      ruleset                  = ruleset
    ).

    " Then
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-interpretationresult
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
    cut->execute(
      EXPORTING
        string_to_be_interpreted = |<TAG>Value1|
        ruleset                  = ruleset
      RECEIVING
        interpretation_result    = DATA(result)
    ).

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
    cut->execute(
      EXPORTING
        string_to_be_interpreted = |<TAG>Value1|
        ruleset                  = ruleset
      RECEIVING
        interpretation_result    = DATA(result)
    ).

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
    cut->execute(
      EXPORTING
        string_to_be_interpreted = |<TAG>Value1|
        ruleset                  = ruleset
      RECEIVING
        interpretation_result    = DATA(result)
    ).

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
    cut->execute(
      EXPORTING
        string_to_be_interpreted = |<B>ResultValue|
        ruleset                  = ruleset
      RECEIVING
        interpretation_result    = DATA(result)
    ).

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
    cut->execute(
      EXPORTING
        string_to_be_interpreted = |<TAG>Value1|
        ruleset                  = ruleset
      RECEIVING
        interpretation_result    = DATA(result)
    ).

    " Then - result is still produced despite event producer failure
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-interpretationresult exp = |Value1| ).
  ENDMETHOD.

ENDCLASS.

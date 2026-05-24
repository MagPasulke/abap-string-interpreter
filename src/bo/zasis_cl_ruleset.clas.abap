CLASS zasis_cl_ruleset DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zasis_if_ruleset.

    ALIASES header FOR zasis_if_ruleset~header.
    ALIASES items  FOR zasis_if_ruleset~items.

    "! Creates an immutable RuleSet container from a header record and its rule items.
    "! @parameter header | RuleSet header data (ID, UUID, description, active flag)
    "! @parameter items  | Ordered collection of rule items belonging to this RuleSet
    "! @raising   zasis_cx_exc | Raised when the header or items are initial (empty)
    METHODS constructor IMPORTING !header TYPE zasis_rulesethd
                                  items   TYPE zasis_tt_rulesetitm
                       RAISING zasis_cx_exc.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZASIS_CL_RULESET IMPLEMENTATION.


  METHOD constructor.

    ASSERT header IS NOT INITIAL.
    ASSERT items IS NOT INITIAL.

    me->header = header.
    me->items  = items.

  ENDMETHOD.
ENDCLASS.

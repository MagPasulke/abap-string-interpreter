@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Ruleset Item Consumption'
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZASIS_C_RULESETITEM
  as projection on ZASIS_I_RULESETITEM
{
  key     RuleSetUUID,
  key     InterpretationItem,
          @Search.defaultSearchElement: true
          IntpretationTarget,
          InterpretationRule,
          @ObjectModel.text.element: [ 'InterpretationTypeText' ]
          InterpretationType,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZASIS_CL_INTERPRETTYPETEXT'
          @Semantics.text: true
  virtual InterpretationTypeText : abap.char( 10 ),
          OffsetPre,
          OffsetPost,
          ReplacementString,
          @Consumption.valueHelpDefinition: [{ entity: { name: 'ZASIS_I_CUSTLOGCAT_VH', element: 'ClassName' } }]
          CustomLogic,
          @Consumption.valueHelpDefinition: [{ entity: { name: 'ZASIS_I_EVTPRODCAT_VH', element: 'ClassName' } }]
          EventProducer,
          /* Associations */
          _Header : redirected to parent ZASIS_C_RULESET,
          _CustLogCatalog,
          _EvtProdCatalog
}

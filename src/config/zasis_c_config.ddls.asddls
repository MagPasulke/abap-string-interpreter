@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Configuration (Consumption)'
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZASIS_C_CONFIG
  provider contract transactional_query
  as projection on ZASIS_I_CONFIG
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'ConfigKeyText' ]
  key ConfigKey,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZASIS_CL_CONFIGKEYTEXT'
      @Semantics.text: true
      virtual ConfigKeyText : abap.char( 60 ),
      ConfigValue,
      @Search.defaultSearchElement: true
      Description,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}

@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Event Producer Catalog (Cons.)'
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZASIS_C_EVTPRODCATALOG
  provider contract transactional_query
  as projection on ZASIS_I_EVTPRODCATALOG
{
      @Search.defaultSearchElement: true
  key ClassName,
      @Search.defaultSearchElement: true
      Description,
      @ObjectModel.text.element: [ 'StatusText' ]
      Status,
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZASIS_CL_CATSTATTEXT'
      @Semantics.text: true
      virtual StatusText : abap.char( 20 ),
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}

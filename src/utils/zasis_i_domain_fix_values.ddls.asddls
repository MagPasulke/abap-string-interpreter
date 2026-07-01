@EndUserText.label: 'ASIS - Read Doma fix values'
@ObjectModel.query.implementedBy: 'ABAP:ZASIS_CL_GET_DOMAIN_FIX_VALUES'
@ObjectModel.resultSet.sizeCategory: #XS
define custom entity ZASIS_I_DOMAIN_FIX_VALUES
{
      @EndUserText.label     : 'domain name'
      @UI.hidden  : true
  key domain_name : sxco_ad_object_name;
      @UI.hidden  : true
  key pos         : abap.numc( 4 );
      @EndUserText.label: 'Key'
      low         : abap.char( 10 );
      @EndUserText.label: 'upper_limit'
      @UI.hidden  : true
      high        : abap.char(10);
      @EndUserText.label     : 'Description'
      @Semantics.text: true
      description : abap.char(60);
}

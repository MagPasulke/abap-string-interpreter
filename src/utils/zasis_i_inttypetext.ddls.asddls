@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ASIS - Read Doma fix values for int. type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZASIS_I_INTTYPETEXT as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZASIS_RULEITEM_TYPE') 
{
    key domain_name,
    key value_position,
    @Semantics.language: true
    key language,
    value_low,
    @Semantics.text: true
    text 
}

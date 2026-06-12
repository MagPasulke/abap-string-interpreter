@EndUserText.label: 'Enhancement Catalog Status'
define type ZASIS_ENHCAT_STATUS : abap.int1 enum
{
  @EndUserText.label: 'Initial'
  initial_value = initial;
  @EndUserText.label: 'Active'
  active = 1;
  @EndUserText.label: 'Deprecated'
  deprecated = 2;
}

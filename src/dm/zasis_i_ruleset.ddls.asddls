@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Ruleset Composite View'
define root view entity ZASIS_I_RULESET as select from ZASIS_I_RULESETHEADER
composition [0..*] of ZASIS_I_RULESETITEM as _Items
{
    key RuleSetUUID,
    RuleSetId,
    Attachment,
    MimeType,
    FileName,
    LastChangedAt,
    LastChangedBy,
    LocalLastChangedAt,
    _Items // Make association public
}

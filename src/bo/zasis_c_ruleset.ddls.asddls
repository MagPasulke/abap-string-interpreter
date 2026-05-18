@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ABAP String Interpreter Service - Ruleset Cons.View'
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZASIS_C_RULESET
provider contract transactional_query as projection on ZASIS_I_RULESET
{
    key RuleSetUUID,
    @Search.defaultSearchElement: true
    RuleSetId,
    @Semantics.largeObject: { mimeType: 'MimeType',   
                       fileName: 'FileName', 
                       acceptableMimeTypes: ['pdf'],
                       contentDispositionPreference: #ATTACHMENT }
    
    Attachment,
    @Semantics.mimeType: true
    MimeType,
    FileName,
    /* Associations */
    _Items : redirected to composition child ZASIS_C_RULESETITEM }  // Make association public

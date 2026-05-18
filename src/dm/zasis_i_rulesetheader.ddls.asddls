@AccessControl.authorizationCheck: #MANDATORY
@EndUserText.label: 'ASIS - Ruleset Header'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZASIS_I_RULESETHEADER
  as select from zasis_rulesethd
{
  key rulesetuuid           as RuleSetUUID,
      rulesetid             as RuleSetId,
      
      attachment            as Attachment,
      @Semantics.mimeType: true
      mimetype              as MimeType,
      filename              as FileName,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt

}

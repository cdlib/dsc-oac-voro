Template that excludes Collection Number if not entered:

cncl.cfg
<titleproper>{$FINDAID_TYPE}{$PROPER_TITLE}</titleproper>
$[<num>Collection number: {$CALL_NO}</num>]$ <-- HERE


$[<unitid label="Collection number" repositorycode="{REPOSITORY_CODE}" countrycode="US">{$CALL_NO}</unitid>]$ <-- HERE
$existing_cp_trusts = @(Get-ADFSClaimsProviderTrust | ForEach-Object { $_.Identifier })
$configured_cp_trusts = @()

$entities = Invoke-RestMethod -Uri http://mdq-beta.incommon.org/global/x-entity-list -Method Get
foreach ($entity in $entities)
{
    ## Download the entity's metadata from the MDQ server.
    $urlEncodedEntityID = [System.Web.HttpUtility]::UrlEncode($entity.entityID)
    $mdqUri = "http://mdq-beta.incommon.org/global/entities/$urlEncodedEntityID"
    $metadataFile = "$pwd\$urlEncodedEntityID.xml"
    Invoke-RestMethod -Uri $mdqUri -Method Get -OutFile $metadataFile
    $metadata = [xml](Get-Content $metadataFile)

    ## Stop here if the entity is not an identity provider.
    if ($metadata.EntityDescriptor.IDPSSODescriptor -eq $null) { continue }

    ## Stop here if the entity does not support REFEDS R&S.
    $filtered = $true
    foreach ($entityAttribute in $metadata.EntityDescriptor.Extensions.EntityAttributes.Attribute)
    {
        if ($entityAttribute.Name -eq 'http://macedir.org/entity-category-support' `
            -and $entityAttribute.NameFormat -eq 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri' `
            -and $entityAttribute.AttributeValue -eq 'http://refeds.org/category/research-and-scholarship')
        {
            $filtered = $false
            break
        }
    }
    if ($filtered) { continue }

    ## Add/update the claims provider trust.
    try
    {
        if ($entity.entityID -in $existing_cp_trusts)
        {
            Update-AdfsClaimsProviderTrust -TargetIdentifier $entity.entityID -MetadataFile $metadataFile
        }
        else
        {
            ## I had problems using the organization names included in the metadata.
            Add-AdfsClaimsProviderTrust -Name $entity.roles[0].displayName -MetadataFile $metadataFile
        }
        $configured_cp_trusts += $entity.entityID
    }
    catch
    {
        Write-Host "Error adding/updating metadata:" $entity.entityID $entity.roles[0].displayName
    }
}

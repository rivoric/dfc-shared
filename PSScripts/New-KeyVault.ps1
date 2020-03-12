<#
.SYNOPSIS
Creates a new Azure Key Vault

.DESCRIPTION
Checks to see if the Key Vault exists and creates one if not

.PARAMETER KeyVaultName
The name of the Key Vault

.PARAMETER ResourceGroupName
Resource group to create the key vault in if it does not exist

.PARAMETER Sku
[Optional] specifies the pricing tier (standard or premium)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String] $KeyVaultName,
    [Parameter(Mandatory=$true)]
    [String] $ResourceGroupName,
    [Parameter(Mandatory=$false)]
    [ValidateSet("Standard","Premium")]
    [String] $Sku = "Standard"
)

$ExistingKeyVault = Get-AzKeyVault -Name $KeyVaultName
if ($ExistingKeyVault) {
    # Ensure key vault is configured with soft delete
    if (-not $ExistingKeyVault.EnableSoftDelete) {
        Write-Output "Adding Soft delete to key vault $KeyVaultName"
        ($resource = Get-AzResource -ResourceId $ExistingKeyVault.ResourceId).Properties | Add-Member -MemberType "NoteProperty" -Name "enableSoftDelete" -Value "true"
        Set-AzResource -resourceid $resource.ResourceId -Properties $resource.Properties -Force
    }
}
else {
    # Create key vault
    Write-Output "Creating key vault $KeyVaultName"
    $ExistingResourceGroup = Get-AzResourceGroup -ResourceGroupName $ResourceGroupName # throws an error if resource group does not exist
    New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroupName -Location $ExistingResourceGroup.Location -Sku $Sku -EnableSoftDelete
}
<#
.SYNOPSIS
    Script that creates a resource group and storage account with container for a Terraform state when unexisting.
.EXAMPLE
    C:\PS> Create-ResourceGroupAndStorageAccount.ps1 -Environment "dev" -ResourceGroupName "rg-abc-dev-weu" -Location "west europe" -StorageAccountName "saabcdevweu" -StorageAccountSku "standard_lrs" -ContainerName "tfstate"
#>
param(
    [Parameter(Mandatory=$True)]
    [String]
    $Environment=$(throw "Short name of the deployment environment."),

    [Parameter(Mandatory=$True)]
    [String]
    $ResourceGroupName=$(throw "Name of the resource group."),

    [Parameter(Mandatory=$True)]
    [String]
    $Location =$(throw "Location of the resource group."),

    [Parameter(Mandatory=$True)]
    [String]
    $StorageAccountName=$(throw "Name of the storage account."),

    [Parameter(Mandatory=$True)]
    [String]
    $StorageAccountSku=$(throw "Sku of the storage account."),

    [Parameter(Mandatory=$True)]
    [String]
    $ContainerName=$(throw "Name of the container in the storage account.")
)

$resourceGroupExists = az group exists --name $ResourceGroupName

if ($resourceGroupExists -eq 'false')
{
  $tags = @("environment=$Environment")
  az group create --name $ResourceGroupName --location $Location --tags $tags
}

$storageAccount = az storage account list --resource-group $ResourceGroupName --query "[?name=='$StorageAccountName']" --output tsv

if ($storageAccount.Length -eq '0')
{
  az storage account create --name $StorageAccountName --resource-group $ResourceGroupName --sku $StorageAccountSku --allow-blob-public-access false --min-tls-version TLS1_2 --public-network-access "Enabled" --https-only true --only-show-errors
  az storage container create --name $ContainerName --account-name $StorageAccountName --auth-mode login
  Write-Host "Storage account $StorageAccountName has been created."
  Start-Sleep -Seconds 60 # Wait for the storage account to be ready and tags to be applied
}

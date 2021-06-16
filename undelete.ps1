param
(
    [Parameter(Mandatory = $True, valueFromPipeline=$true)]
    [String] $SubscriptionId,

    [Parameter(Mandatory = $True, valueFromPipeline=$true)]
    [String] $ResourceGroup,

    [Parameter(Mandatory = $True, valueFromPipeline=$true)]
    [String] $StorageAccount,

    [Parameter(Mandatory = $False, valueFromPipeline=$true)]
    [String] $StorageAccountKey,

    [Parameter(Mandatory = $True, valueFromPipeline=$true)]
    [String] $Container,
    
    [Parameter(Mandatory = $False, valueFromPipeline=$true)]
    [String] $Prefix,

    [Parameter(Mandatory = $True, valueFromPipeline=$true)]
    [String] $OutputFile
)

if ($StorageAccountKey -eq $Null -or $StorageAccountKey -eq "") 
{
    # Connect to the Azure Subscritpion
    Connect-AzAccount -Subscription $SubscriptionId

    # Connect to the Storage Namespace
    $StorageAccountKey = ((Get-AzStorageAccountKey -ResourceGroupName $ResourceGroup -Name $StorageAccount) | Where-Object {$_.KeyName -eq "key1"}).Value
}

# Create storage auth context
$StorageAccountContext = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageAccountKey

# Loop all matching objects for inventorization
$MaxResults = 5000
$TotalResults = 0
$TotalSize = 0
$ContinuationToken = $Null

Do 
{
    if ($Prefix -eq $null -or $Prefix -eq "") 
    {
        $Blobs = Get-AzStorageBlob -IncludeDeleted -Context $StorageAccountContext -Container $Container -MaxCount $MaxResults -ContinuationToken $ContinuationToken
    }
    else
    {
        $Blobs = Get-AzStorageBlob -IncludeDeleted -Context $StorageAccountContext -Container $Container -Prefix $Prefix -MaxCount $MaxResults -ContinuationToken $ContinuationToken
    }
        
    if ($Blobs.Length -le 0) { Break; }

    $ContinuationToken = $Blobs[$Blobs.Count - 1].ContinuationToken;

    $ItemBuilder = [System.Text.StringBuilder]::new()
    
    $Blobs | ForEach-Object { 
        [void]$ItemBuilder.AppendLine("$($_.Name),$($_.Length),$($_.IsDeleted)") 
        $TotalSize += $_.Length

        if($_.IsDeleted)
        {
            
            # Invoke-RestMethod? https://myaccount.blob.core.windows.net/mycontainer/myblob?comp=undelete	
        }
    } 
    
    Add-Content $OutputFile $ItemBuilder.ToString().Trim()

}
While ($ContinuationToken -ne $Null)


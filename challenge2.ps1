$ClientId = '{YOUR CLIENT ID}'
$ClientSecret = '{YOUR CLIENT SECRET}'
$TenantId ='{YOUR TENANT ID}'
$SubscriptionId ='{YOUR SUBSCRIPTION ID}'
$azurePassword = ConvertTo-SecureString "$ClientSecret" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($ClientId , $azurePassword)
Connect-AzAccount -Credential $psCred -TenantId $TenantId -ServicePrincipal

$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
   'Content-Type'='application/json'
   'Authorization'='Bearer ' + $token.AccessToken
}

$u = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/{rESOURCEGROUPNAME}/providers/Microsoft.Compute/snapshots?api-version=2021-12-01"

$getSnapshotList = Invoke-RestMethod -Method Get -Uri $u -Headers $authHeader

$getSnapshotList | ConvertTo-Json

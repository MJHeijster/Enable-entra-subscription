$tenantId = ''
$subscriptionName = ''
$justification = 'work'

Connect-AzAccount -TenantId $tenantId

Get-AzRoleEligibilitySchedule -Scope "/" -Filter "asTarget()" `
| Where-Object { $_.ScopeDisplayName -eq $subscriptionName } `
| Group-Object RoleDefinitionDisplayName, Scope `
| Select-Object @{ Expression = { $_.group[0] } ; Label = 'Item' } `
| Select-Object -ExpandProperty item `
| ForEach-Object {
    $p = @{
        Name                      = (New-Guid).Guid
        Scope                     = $_.Scope
        PrincipalId               = (Get-AzADUser -SignedIn).Id
        RoleDefinitionId          = $_.RoleDefinitionId
        ScheduleInfoStartDateTime = Get-Date -Format o
    }
    New-AzRoleAssignmentScheduleRequest @p -ExpirationDuration PT8H -ExpirationType AfterDuration -RequestType SelfActivate -Justification $justification
}

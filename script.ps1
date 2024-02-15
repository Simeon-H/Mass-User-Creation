# For each of the new OUs being created: first the Marvel OU is recorded and then each separate group is placed into that OU
New-ADOrganizationalUnit -Name "Marvel" -Path "DC=Simeon,DC=moc"
New-ADOrganizationalUnit -Name "HR" -Path "OU=Marvel,DC=Simeon,DC=moc"
New-ADOrganizationalUnit -Name "Sales" -Path "OU=Marvel,DC=Simeon,DC=moc"
New-ADOrganizationalUnit -Name "Engineering" -Path "OU=Marvel,DC=Simeon,DC=moc"
New-ADOrganizationalUnit -Name "Accounting" -Path "OU=Marvel,DC=Simeon,DC=moc"
New-ADOrganizationalUnit -Name "IT" -Path "OU=Marvel,DC=Simeon,DC=moc"
New-ADOrganizationalUnit -Name "Research" -Path "OU=Marvel,DC=Simeon,DC=moc"
New-ADOrganizationalUnit -Name "Development" -Path "OU=Marvel,DC=Simeon,DC=moc"
New-ADOrganizationalUnit -Name "Executive" -Path "OU=Marvel,DC=Simeon,DC=moc"

$Csvfile = "C:\Users\SimeonAdmin\Desktop\List_of_Users.csv"
$Users = Import-Csv $Csvfile


# Loop through each user
foreach ($User in $Users) {
    $GivenName = $User.GivenName
    $Surname = $User.Surname
    $DisplayName = $User.Displayname
    $SamAccountName = $User.SamAccountName
    $UserPrincipalName = $User.UserPrincipalName
    $Department = $User.Department
    $OU = $User.path
    

    # Create new user parameters
    $NewUserParams = @{
        Name                  = $User.Name
        GivenName             = $GivenName
        Surname               = $Surname
        DisplayName           = $DisplayName
        SamAccountName        = $SamAccountName
        UserPrincipalName     = $UserPrincipalName
        Department            = $Department
        Path                  = $OU
        AccountPassword       = (ConvertTo-SecureString $User.password -AsPlainText -Force)
        Enabled               = if ($AccountStatus -eq "Enabled") { $true } else { $false }
        ChangePasswordAtLogon = $true # Set the "User must change password at next logon" flag
    }

    try {
        # Create the new AD user
        New-ADUser @NewUserParams
        Write-Host "User $SamAccountName created successfully." -ForegroundColor Cyan
    }
    catch {
        # Failed to create the new AD user
        $ErrorMessage = $_.Exception.Message
        if ($ErrorMessage -match "The password does not meet the length, complexity, or history requirement") {
            Write-Warning "User $SamAccountName created but the account is disabled. $_"
        }
        else {
            Write-Warning "Failed to create user $SamAccountName. $_"
        }
    }
}

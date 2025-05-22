

# Example data: list of users and groups to create
# Example data: list of 20 users and groups to create
$users = @(
    @{ UserName = "alice.smith"; FirstName = "Alice"; LastName = "Smith"; GroupName = "corpAdmins" },
    @{ UserName = "bob.jones"; FirstName = "Bob"; LastName = "Jones"; GroupName = "corpUsers" },
    @{ UserName = "carol.lee"; FirstName = "Carol"; LastName = "Lee"; GroupName = "corpUsers" },
    @{ UserName = "david.kim"; FirstName = "David"; LastName = "Kim"; GroupName = "corpAdmins" },
    @{ UserName = "emma.brown"; FirstName = "Emma"; LastName = "Brown"; GroupName = "corpUsers" },
    @{ UserName = "frank.wilson"; FirstName = "Frank"; LastName = "Wilson"; GroupName = "corpUsers" },
    @{ UserName = "grace.taylor"; FirstName = "Grace"; LastName = "Taylor"; GroupName = "corpAdmins" },
    @{ UserName = "henry.moore"; FirstName = "Henry"; LastName = "Moore"; GroupName = "corpUsers" },
    @{ UserName = "irene.miller"; FirstName = "Irene"; LastName = "Miller"; GroupName = "corpUsers" },
    @{ UserName = "jack.davis"; FirstName = "Jack"; LastName = "Davis"; GroupName = "corpAdmins" },
    @{ UserName = "kate.evans"; FirstName = "Kate"; LastName = "Evans"; GroupName = "corpUsers" },
    @{ UserName = "leo.harris"; FirstName = "Leo"; LastName = "Harris"; GroupName = "corpUsers" },
    @{ UserName = "mia.clark"; FirstName = "Mia"; LastName = "Clark"; GroupName = "corpAdmins" },
    @{ UserName = "nina.lewis"; FirstName = "Nina"; LastName = "Lewis"; GroupName = "corpUsers" },
    @{ UserName = "oliver.walker"; FirstName = "Oliver"; LastName = "Walker"; GroupName = "corpUsers" },
    @{ UserName = "paul.hall"; FirstName = "Paul"; LastName = "Hall"; GroupName = "corpAdmins" },
    @{ UserName = "quinn.allen"; FirstName = "Quinn"; LastName = "Allen"; GroupName = "corpUsers" },
    @{ UserName = "ruby.young"; FirstName = "Ruby"; LastName = "Young"; GroupName = "corpUsers" },
    @{ UserName = "sam.king"; FirstName = "Sam"; LastName = "King"; GroupName = "corpAdmins" },
    @{ UserName = "tina.scott"; FirstName = "Tina"; LastName = "Scott"; GroupName = "corpUsers" }
)

# Create groups if they do not exist
$groups = $users | Select-Object -ExpandProperty GroupName | Sort-Object -Unique
foreach ($group in $groups) {
    if (-not (Get-ADGroup -Filter { Name -eq $group } -ErrorAction SilentlyContinue)) {
        Write-Host "Creating group: $group"
        New-ADGroup -Name $group -SamAccountName $group -GroupScope Global -GroupCategory Security -Path "OU=Group,DC=corp,DC=local"
    } else {
        Write-Host "Group $group already exists."
    }
}

# Create users if they do not exist and add them to their groups
foreach ($user in $users) {
    $username = $user.UserName
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $group = $user.GroupName

    if (-not (Get-ADUser -Filter { SamAccountName -eq $username } -ErrorAction SilentlyContinue)) {
        Write-Host "Creating user: $username"
        New-ADUser -Name "$firstName $lastName" `
                   -GivenName $firstName `
                   -Surname $lastName `
                   -SamAccountName $username `
                   -UserPrincipalName "$username@corp.local" `
                   -Path "CN=Users,DC=corp,DC=local" `
                   -AccountPassword (ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force) `
                   -Enabled $true
    } else {
        Write-Host "User $username already exists."
    }

    # Add user to group if not already a member
    $isMember = (Get-ADGroupMember -Identity $group -Recursive | Where-Object { $_.SamAccountName -eq $username }) -ne $null
    if (-not $isMember) {
        Write-Host "Adding $username to $group"
        Add-ADGroupMember -Identity $group -Members $username
    } else {
        Write-Host "$username is already a member of $group"
    }
}
# Set path to the JSON file in the Jenkins workspace
                \$jsonPath = "\$env:JSON_FILE_PATH"

                # Read the content of the JSON file and convert it to an array of PowerShell objects
                \$users = Get-Content \$jsonPath | ConvertFrom-Json

                # Get the current date to compare against StartDate
                \$today = Get-Date

                # Loop through each user in the JSON file
                foreach (\$user in \$users) {
                    # Convert StartDate from string to DateTime object
                    \$startDate = [datetime]::ParseExact(\$user.StartDate, 'yyyy-MM-dd', \$null)

                    # Determine if the StartDate is within the last 30 days
                    \$within30Days = (\$today - \$startDate).Days -le 30

                    # Loop through all the groups this user should belong to
                    foreach (\$group in \$user.GroupNames) {

                        # Check if the user is currently a member of the group
                        \$isMember = Get-ADGroupMember -Identity \$group -Recursive | Where-Object { \$_.SamAccountName -eq \$user.SamAccountName }

                        # If the user should be in the group (StartDate <= 30 days ago)
                        if (\$within30Days) {
                            if (-not \$isMember) {
                                # User is not in the group — add them
                                try {
                                    Add-ADGroupMember -Identity \$group -Members \$user.SamAccountName -ErrorAction Stop
                                    Write-Host " Added \$(\$user.SamAccountName) to \$group"
                                } catch {
                                    # Log if the add operation fails
                                    Write-Warning " Failed to add \$(\$user.SamAccountName) to \$group: \$_"
                                }
                            } else {
                                # User is already in the group — no action needed
                                Write-Host " \$(\$user.SamAccountName) already in \$group"
                            }
                        }
                        else {
                            # If user is past the 30-day window, they should be removed
                            if (\$isMember) {
                                try {
                                    # Remove the user from the group (skip confirmation prompt)
                                    Remove-ADGroupMember -Identity \$group -Members \$user.SamAccountName -Confirm:\$false -ErrorAction Stop
                                    Write-Host " Removed \$(\$user.SamAccountName) from \$group"
                                } catch {
                                    # Log if the remove operation fails
                                    Write-Warning " Failed to remove \$(\$user.SamAccountName) from \$group: \$_"
                                }
                            } else {
                                # User is not in the group already — no removal needed
                                Write-Host "  \$(\$user.SamAccountName) not in \$group — no action needed"
                            }
                        }
                    }
                }
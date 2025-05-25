      <//  stage('Upload JSON to Repo') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'e081ec0d-a4eb-42cc-865b-911e79062935', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    powershell '''
                        git config user.name "$env:GIT_USERNAME"
                        git config user.email "$env:GIT_USERNAME@example.com"

                        # Ensure we are on the correct branch (main or your target branch)
                        git checkout main
                        git pull origin main  # Ensure your branch is up-to-date

                        # Check if there are changes and commit
                        git add .
                        $commitResult = git commit -m "${env.date} commit for changes"
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "Changes committed"
                        } else {
                            Write-Host "No changes to commit"
                        }

                        # Set remote URL with embedded credentials
                        git remote set-url origin https://$env:GIT_USERNAME:$env:GIT_PASSWORD@github.com/Moshe832/jenkinsfiles.git

                        # Push changes
                        git push origin main
                    '''

                    powershell '''
                        # Define file path
                        $uateJsonTmp = "$env:UpdateJsonTmp"
                        echo "path : $uateJsonTmp"
                        Copy-Item -Recurse "$uateJsonTmp" "C:\\Users\\Moshe\\Desktop\\UpdateJson@tmp"
                    '''
                }
            }
        }
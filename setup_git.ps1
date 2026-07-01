# Git setup and push script
Set-Location "c:\Users\JanakiRaman\Downloads\bitbucket\jenkins"

# Configure git identity
git config --global user.email "janakiramanG@example.com"
git config --global user.name "JanakiramanG"

# Verify git identity
Write-Host "Git user: $(git config --global user.name)"
Write-Host "Git email: $(git config --global user.email)"

# Stage all files
git add .

# Commit
git commit -m "feat: modular Terraform for Jenkins on AWS - NLB->ALB->EC2 with ACM"

# Set branch to main
git branch -M main

# Push to GitHub
git push -u origin main

Write-Host "Done! Code pushed to https://github.com/JanakiramanG/jenkins"

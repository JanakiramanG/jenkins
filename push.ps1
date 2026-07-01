Set-Location "c:\Users\JanakiRaman\Downloads\bitbucket\jenkins"

# Stage the deleted setup_git.ps1 and updated README
git add -A

# Show what is staged
git status

# Commit
git commit -m "docs: update README with author janakiraman_g (Jan 2026); remove setup_git.ps1"

# Push to main
git push origin main

Write-Host "Push complete."

#!/usr/bin/env pwsh
$ErrorActionPreference = "Continue"

Write-Host "Current directory: $(Get-Location)"
Write-Host "Initializing git repository..."

git init
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Git initialized"
} else {
    Write-Host "❌ Git init failed with code $LASTEXITCODE"
}

Write-Host "Configuring git user..."
git config user.email "dev@local"
git config user.name "AI Glasses Dev"

Write-Host "Adding files..."
git add .
Write-Host "Committing..."
git commit -m "Initial commit: AI Smart Glasses Flutter app"

Write-Host "Adding remote..."
git remote add origin "https://github.com/Aon371/ai_glasses.git"

Write-Host "Setting up main branch..."
git branch -M main

Write-Host "Pushing to GitHub..."
git push -u origin main

Write-Host "✅ Done!"

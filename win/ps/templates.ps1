function nbp {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("go", "python", "javascript", "ruby")]
        [string]$l,

        [Parameter(Mandatory=$true)]
        [string]$n
    )

    # Use $PSScriptRoot instead of $MyInvocation.MyCommand.Path
    # $PSScriptRoot is available in script/module context, not in the console.
    $templatesDir = Join-Path $PSScriptRoot "templates"
    $templateFile = Join-Path $templatesDir ("$l.txt")

    if (!(Test-Path $templateFile)) {
        Write-Host "Template for language '$l' not found at '$templateFile'." -ForegroundColor Red
        return
    }

    $projectDir = Join-Path (Get-Location) $n
    if (Test-Path $projectDir) {
        Write-Host "Directory '$n' already exists. Aborting." -ForegroundColor Red
        return
    }

    # Read the template
    $templateContent = Get-Content $templateFile -Raw

    # Replace placeholders
    $templateContent = $templateContent -replace "{{PROJECT_NAME}}", $n

    # Create project directory
    New-Item -ItemType Directory -Path $projectDir | Out-Null

    # Determine output filename based on language
    $outputFilename = switch($l) {
        "go" { "main.go" }
        "python" { "main.py" }
        "javascript" { "index.js" }
        "ruby" { "main.rb" }
    }

    # Write template to output file
    Set-Content (Join-Path $projectDir $outputFilename) $templateContent

    # Optionally create a README.md
    $readmeContent = "# $n`nA starter $l project."
    Set-Content -Path (Join-Path $projectDir "README.md") -Value $readmeContent

    Write-Host "Boilerplate $l project '$n' created successfully!" -ForegroundColor Green
}


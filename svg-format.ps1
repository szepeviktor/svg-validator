# Requires xmlstarlet and xmllint in PATH
# derived from https://github.com/szepeviktor/svg-validator/blob/master/svg-format.sh

# Usage: .\svg-format.ps1 <path-to-svg-file>
# pre-requisites: xmlstarlet, xmllint
# For Windows with Chocolatey:
# choco install xsltproc
# choco install xmlstarlet

param (
    [Parameter(Mandatory = $true)]
    [string]$SVGFilePath
)

if (-not (Test-Path $SVGFilePath)) {
    Write-Error "File not found or not readable: $SVGFilePath"
    exit 1
}

# Create the formatted/ directory if it doesn't exist.
New-Item -ItemType Directory -Path "formatted" -Force | Out-Null

# Step 1: Remove the xml:space attribute using xmlstarlet.
$result1 = & xml edit -N "svg=http://www.w3.org/2000/svg" --delete '//svg:svg/@xml:space' $SVGFilePath

# Step 2: Format the XML using xmllint.
$env:XMLLINT_INDENT = "    "
$result2 = $result1 | & xmllint --format -

# Step 3: Append the xml:space="preserve" attribute back using xmlstarlet.
$result3 = $result2 | & xml edit --pf -N "svg=http://www.w3.org/2000/svg" --append '//svg:svg' --type attr -n "xml:space" --value "preserve"

# Write the formatted output to the formatted/ directory.
$outputFile = Join-Path "formatted" (Split-Path $SVGFilePath -Leaf)
$result3 | Set-Content -Encoding UTF8 $outputFile

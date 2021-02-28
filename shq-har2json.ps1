param (
    [Parameter(Mandatory = $true)]
    [string] $HarFilePath
)

# The result JSON file create at the same location of $harFilePath.
$jsonFilePath = Join-Path -Path ([IO.Path]::GetDirectoryName($harFilePath)) -ChildPath ([IO.Path]::GetFileNameWithoutExtension($harFilePath) + '.json')

$keyTextPattarn = '"text": "{\"FormSessionID\":'

Set-Content -LiteralPath $jsonFilePath -Encoding utf8 -Value '[' -Force 

Select-String -LiteralPath $harFilePath -SimpleMatch -Pattern $keyTextPattarn -Raw |
    ForEach-Object -Process {
        $_.Trim().
            Replace('"text": "', '').
            Replace('\"', '"').
            Replace('\\"', '\"') -replace '"$', ','
    } |
    Add-Content -LiteralPath $jsonFilePath -Encoding utf8

Add-Content -LiteralPath $jsonFilePath -Encoding utf8 -Value ']'

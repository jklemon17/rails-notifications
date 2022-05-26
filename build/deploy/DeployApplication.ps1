param(
    [string] $applicationName = $null,
    [string] $branchName = $null,
    [string] $commitHash = $null
)

pushd $PSScriptRoot
pushd "../../"

eb init

$envName = $applicationName.Replace(".", "-")
$envs = eb list | Out-String
If (!($envs -Match $envName)) {
    try { 
        eb create "$branchName-$envName" 
    } catch {
        Write-Output "EB env already created." 
    }
}
eb use "$branchName-$envName"
eb deploy

popd
popd
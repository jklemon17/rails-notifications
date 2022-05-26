param(
    [string] $applicationName = $null,
    [string] $branchName = $null,
    [string] $commitHash = $null
)

pushd $PSScriptRoot
pushd "../../"

$sslKeyArn = (aws ssm get-parameters --region us-east-1 --names "/$branchName/sslKeyArn" | ConvertFrom-Json).Parameters[0].Value
(Get-Content "./.ebextensions/02-LoadBalancer.config").replace('$SSL_CERT_ARN', $sslKeyArn) | Set-Content "./.ebextensions/03-LoadBalancer.config"

(Get-Content "./.elasticbeanstalk/config.yml").replace('$CIRCLE_SHA1', $commitHash).replace('$CIRCLE_BRANCH', $branchName).replace('$APP_NAME', $applicationName) | Set-Content "./.elasticbeanstalk/config.yml"

$rubyEnv = "development"
If ($branchName -eq "master") {
    $rubyEnv = "production"
}
$secretKeyBase = (aws ssm get-parameters --region us-east-1 --names "/$branchName/secretKeyBase" --with-decryption | ConvertFrom-Json).Parameters[0].Value
$databaseUrl = (aws ssm get-parameters --region us-east-1 --names "/$branchName/databaseUrl" --with-decryption | ConvertFrom-Json).Parameters[0].Value

$environmentVars = @{
    "option_settings"=@(
        @{
            "option_name"="DATABASE_URL";
            "value"=$databaseUrl;
        }, @{
            "option_name"="RAILS_ENV";
            "value"=$rubyEnv;
        }, @{
            "option_name"="RACK_ENV";
            "value"=$rubyEnv;
        }, @{
            "option_name"="SECRET_KEY_BASE";
            "value"=$secretKeyBase;
        }, @{
            "option_name"="BUNDLER_VERSION";
            "value"="2.0.2";
        }, @{
            "option_name"="LOGGING";
            "value"="debug";
        }, @{
            "option_name"="RAILS_SKIP_MIGRATIONS";
            "value"="true";
        }, @{
            "option_name"="BUNDLE_WITHOUT";
            "value"="test";
        }
    )
}

# https://github.com/cloudbase/powershell-yaml
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module powershell-yaml -Force
Import-Module powershell-yaml

ConvertTo-Yaml $environmentVars | Out-File -FilePath "./.ebextensions/99-EnvironmentVariables.config"

popd

popd
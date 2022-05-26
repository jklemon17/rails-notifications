param(
    [string] $branchName = $null
)

pushd $PSScriptRoot
pushd "../../"

$conn = (aws ssm get-parameters --region us-east-1 --names "/$branchName/databaseUrl" --with-decryption | ConvertFrom-Json).Parameters[0].Value

$rubyEnv = "development"
If ($branchName -eq "master") {
    $rubyEnv = "production"
}

$env:DATABASE_URL=$conn 
$env:RAILS_ENV=$rubyEnv 
# done inside CircleCI for caching
# bundle install
bundle exec rake db:create 
bundle exec rake db:migrate 

popd
popd

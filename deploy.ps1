# Load email config from JSON
$emailConfig = Get-Content -Raw -Path "email-config.json" | ConvertFrom-Json

$EmailFrom   = $emailConfig.EmailFrom
$EmailTo     = $emailConfig.EmailTo
$Subject     = $emailConfig.Subject
$Body        = $emailConfig.Body
$SMTPServer  = $emailConfig.SMTPServer
$SMTPPort    = $emailConfig.SMTPPort
$Username    = $emailConfig.Username
$Password    = $emailConfig.AppPassword

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)

# Exit if any command fails
$ErrorActionPreference = "Stop"

# Step 1: Deploy ECS Backend
Write-Host "Deploying ECS Backend..."
terraform -chdir=terraform/backend init
terraform -chdir=terraform/backend apply -auto-approve

# Step 2: Fetch ALB DNS Name from Terraform Output
$albDns = terraform -chdir=terraform/backend output -raw alb_dns_name

if ([string]::IsNullOrEmpty($albDns)) {
    Write-Host "ERROR: ALB DNS name not found. Exiting..."
    exit 1
}

# Step 3: Update frontend config.json
Write-Host "Updating frontend config.json..."
$configFile = "frontend\src\config.json"
$backendUrl = "http://${albDns}"
$jsonContent = "{`"backendUrl`": `"$backendUrl`"}"
$jsonContent | Out-File -Encoding utf8 -FilePath $configFile

# Step 4: Build the Frontend
Write-Host "Building frontend..."
cd frontend
npm install
npm run build
cd ..

# Step 5: Deploy Updated Frontend to S3
Write-Host "Deploying frontend to S3..."
terraform -chdir=terraform/frontend init
terraform -chdir=terraform/frontend apply -auto-approve

Write-Host "Deployment Complete!"

Send-MailMessage -From $EmailFrom -To $EmailTo -Subject "Resources Created" -Body "Resources created successfully!" -SmtpServer $SMTPServer -Port $SMTPPort -Credential $Credential -UseSsl
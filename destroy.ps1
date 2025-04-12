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

terraform -chdir=terraform/frontend destroy -auto-approve
terraform -chdir=terraform/backend destroy -auto-approve

Send-MailMessage -From $EmailFrom -To $EmailTo -Subject "Resources Destroyed" -Body "Resources destroyed successfully!" -SmtpServer $SMTPServer -Port $SMTPPort -Credential $Credential -UseSsl
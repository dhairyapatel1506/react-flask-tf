# Exit if any command fails
$ErrorActionPreference = "Stop"

# Step 1: Deploy ECS Backend
Write-Host "Deploying ECS Backend..."
terraform -chdir=terraform/backend init
terraform -chdir=terraform/backend apply -auto-approve

# Step 2: Wait for ECS Task to Start & Fetch Public IP
Write-Host "Waiting for ECS Task to Start..."
Start-Sleep -Seconds 20  # Give some time for the task to register

# Try fetching task ARN multiple times
$maxAttempts = 10
$attempt = 0
$taskArn = ""

while ($attempt -lt $maxAttempts -and [string]::IsNullOrEmpty($taskArn)) {
    $taskArn = aws ecs list-tasks --cluster flask-app-cluster --query 'taskArns[0]' --output text
    if ([string]::IsNullOrEmpty($taskArn) -or $taskArn -eq "None") {
        Write-Host "No running tasks found, retrying in 10 seconds..."
        Start-Sleep -Seconds 10
        $attempt++
    }
    else {
        break
    }
}

if ([string]::IsNullOrEmpty($taskArn) -or $taskArn -eq "None") {
    Write-Host "ERROR: No ECS tasks found after multiple attempts. Exiting..."
    exit 1
}

Write-Host "Found Task: $taskArn"

# Fetch the network interface ID
$eniId = aws ecs describe-tasks --cluster flask-app-cluster --tasks $taskArn --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text

# Get Public IP (Retry if necessary)
$taskPublicIP = ""
$attempt = 0

while ($attempt -lt $maxAttempts -and ([string]::IsNullOrEmpty($taskPublicIP) -or $taskPublicIP -eq "None")) {
    $taskPublicIP = aws ec2 describe-network-interfaces --network-interface-ids $eniId --query 'NetworkInterfaces[0].Association.PublicIp' --output text
    if ([string]::IsNullOrEmpty($taskPublicIP) -or $taskPublicIP -eq "None") {
        Write-Host "Public IP not available yet, retrying in 10 seconds..."
        Start-Sleep -Seconds 10
        $attempt++
    }
    else {
        break
    }
}

if ([string]::IsNullOrEmpty($taskPublicIP) -or $taskPublicIP -eq "None") {
    Write-Host "ERROR: Could not retrieve the public IP. Exiting..."
    exit 1
}

Write-Host "Backend is running at: $taskPublicIP"

# Step 3: Update frontend config.json
Write-Host "Updating frontend config.json..."
$configFile = "frontend\src\config.json"
$backendUrl = "http://${taskPublicIP}:5000"
$jsonContent = "{`"backendUrl`": `"$backendUrl`"}"
$jsonContent | Out-File -Encoding utf8 -FilePath $configFile

# Debugging: Check updated config file
Write-Host "Updated config.json content:"
Get-Content $configFile

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
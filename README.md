# AWS Systems Manager Operations Suite: Run Command, Automation, State Manager & Patch Manager

## OVERVIEW
Modern cloud operations demand secure, scalable, and agent-driven fleet management without relying on legacy bastion hosts, manual SSH logins, or open inbound management ports. 
AWS Systems Manager (SSM) provides a unified operational hub to remotely execute commands, automate multi-step workflows, enforce desired server configurations, and maintain operating system patch compliance across Amazon EC2 instances and on-premises managed nodes.

## THIS COMPREHENSIVE GUIDE COVERS FOUR CORE PILLARS OF AWS SYSTEMS MANAGER OPERATIONS:
AWS Systems Manager Run Command: Execute ad-hoc shell scripts and custom YAML command documents across multiple EC2 instances simultaneously without SSH, streaming real-time installation outputs directly to Amazon CloudWatch Logs.

AWS Systems Manager Automation (Runbooks): Orchestrate multi-step operational workflows by verifying instance state, installing web servers, capturing golden Amazon Machine Images (AMIs), and extracting runtime outputs via embedded Python scripts.

AWS Systems Manager State Manager: Enforce continuous configuration compliance and drift remediation through scheduled associations that periodically verify and restore desired server states, archiving execution logs to Amazon S3.

AWS Systems Manager Patch Manager: Automate vulnerability scanning, OS baseline compliance reporting, and security patch installations across fleets using AWS-RunPatchBaseline.


## MODULE 1: REMOTELY EXECUTE COMMANDS WITH AWS SYSTEMS MANAGER RUN COMMAND

Run Command enables administrators to safely execute administrative tasks—such as installing software packages or updating configurations—across multiple managed nodes without opening port 22 or managing SSH key pairs. 
In this module, you will author a custom SSM Command Document (install-httpd) to deploy the Apache HTTP server across multiple Amazon Linux instances and stream stdout/stderr execution logs to Amazon CloudWatch Logs.

#### ACCESS PROJECT MATERIALS
#### PDF GUIDE: [REMOTELY EXECUTE RUN COMMANDS ON MANAGED EC2 INSTANCES WITH AWS SYSTEMS MANAGER RUN COMMAND.pdf](https://github.com/user-attachments/files/35066029/REMOTELY.EXECUTE.RUN.COMMANDS.ON.MANAGED.EC2.INSTANCES.WITH.AWS.SYSTEMS.MANAGER.RUN.COMMAND.pdf)

#### WATCH VIDEO WALKTHROUGH HERE: https://youtu.be/xSofW2BzSLc

### STEP-BY-STEP DEPLOYMENT GUIDE

STEP 1: Create IAM Role for EC2 and CloudWatch:
1) Navigate to IAM > Roles > Create role.
2) Select AWS service as the trusted entity and choose EC2.
3) Attach the following AWS managed policies:
   AmazonSSMManagedInstanceCore (enables SSM Agent communication)
   CloudWatchFullAccess (enables streaming command logs to CloudWatch)
4) Name the role runcommand-role and create it.


STEP 2: Launch Managed EC2 Instances
1) Launch two EC2 instances using the latest Amazon Linux AMI (which includes the SSM Agent pre-installed).
2) Configure Security Group inbound rules to allow HTTP (Port 80) traffic.
3) Under Advanced details > IAM instance profile, attach runcommand-role.
4) Navigate to Systems Manager > Fleet Manager to confirm both instances appear as managed nodes.

Step 3: Create a Custom SSM Command Document
1) Navigate to Systems Manager > Documents > Create document > Command or session.
2) Name the document install-httpd and set Content format to YAML.
3) Click Create document.


STEP 4: Create a CloudWatch Log Group
1) Navigate to CloudWatch > Log groups > Create log group.
2) Enter httpd-logs as the Log group name and click Create.

STEP 5: Execute Run Command Across Instances
1) Go to Systems Manager > Run Command > Run a command.
2) Under Command document, filter by Owned by me and select install-httpd.
3) Under Target selection, select Choose instances manually and check both EC2 instances.
4) Under Output options, uncheck Enable an S3 bucket, check Enable CloudWatch logs, and enter httpd-logs as the log group name.
5) Click Run and wait for the overall status to reach Success.


STEP 6: Verify Web Server & CloudWatch Logs
1) Open http://<EC2-PUBLIC-IPV4> in your browser for both instances to confirm Hello Cloud Learners is served.
2) Open CloudWatch > Log groups > httpd-logs and inspect the stdout and stderr log streams to audit command execution.


## MODULE 2: AUTOMATE OPERATIONAL TASKS WITH AWS SYSTEMS MANAGER AUTOMATION (RUNBOOKS)

AWS Systems Manager Automation simplifies complex, multi-step IT workflows into repeatable, self-service Runbooks. 
In this module, you will build a custom Automation Runbook (install-httpd-for-new-ami) that validates an EC2 instance's running state, installs Apache HTTPD, captures a golden Amazon Machine Image (AMI), and executes an inline Python script to output the new AMI ID—enabling pre-configured server deployments without post-boot installation scripts.

#### ACCESS PROJECT MATERIALS
#### PDF GUIDE: [AUTOMATE OPERATIONAL TASKS WITH AWS SYSTEMS MANAGER AUTOMATION.pdf](https://github.com/user-attachments/files/35066253/AUTOMATE.OPERATIONAL.TASKS.WITH.AWS.SYSTEMS.MANAGER.AUTOMATION.pdf)

#### WATCH VIDEO WALKTHROUGH HERE: https://youtu.be/g07PSTffTxQ

### STEP-BY-STEP DEPLOYMENT GUIDE

STEP 1: Create EC2 Instance IAM Role
1) Create an IAM role for EC2 named firstinstance-role.
2) Attach the AmazonSSMManagedInstanceCore policy.


STEP 2: Launch Source EC2 Instance
1) Launch an Amazon Linux EC2 instance named first-instance.
2) Allow inbound HTTP (Port 80) traffic and attach firstinstance-role.
3) Confirm registration in Systems Manager > Fleet Manager

STEP 3: Create IAM Role for Systems Manager Automation
1) Navigate to IAM > Roles > Create role, select AWS service, and choose Systems Manager.
2) Attach the following managed policies:
   AmazonEC2FullAccess (allows SSM Automation to describe instances and create AMIs)
   AmazonSSMFullAccess (allows SSM Automation to invoke Run Command steps)
3) Name the role automation-role and create it.

STEP 4: Create the Automation Runbook Document
1) Navigate to Systems Manager > Documents > Create document > Automation.
2) Name the runbook install-httpd-for-new-ami.
3) Switch to the Code editor, and clear the default template.
4) Click Create runbook.

STEP 5: Execute the Automation Runbook
1) Go to Systems Manager > Documents > Owned by me, select install-httpd-for-new-ami, and click Execute automation.
2) Choose Simple execution.
3) Under Input parameters, select first-instance for InstanceId and automation-role for AutomationAssumeRole.
4) Click Execute and monitor all four workflow steps until completion. Copy the generated AMI ID from the Outputs panel.

STEP 6: Launch and Verify a New Instance from the Golden AMI
1) Navigate to EC2 > Images > AMIs, select your newly created AMI, and click Launch instance from AMI.
2) Name the instance second-instance, allow HTTP (Port 80) inbound traffic, and launch.
3) Once initialized, open http://<SECOND-INSTANCE-PUBLIC-IPV4> in your browser to verify Apache serves Hello Cloud Learners immediately out of the box.


## MODULE 3: ENFORCE CONFIGURATION COMPLIANCE WITH AWS SYSTEMS MANAGER STATE MANAGER

While Run Command handles one-time executions, AWS Systems Manager State Manager provides continuous configuration management and automated drift remediation at no additional charge. By defining Associations with recurring schedules, State Manager periodically inspects managed instances and automatically reapplies desired configurations whenever drift occurs.

#### ACCESS PROJECT MATERIALS
#### PDF GUIDE: [AWS SYSTEMS MANAGER STATE MANAGER.pdf](https://github.com/user-attachments/files/35066852/AWS.SYSTEMS.MANAGER.STATE.MANAGER.pdf)

#### WATCH VIDEO WALKTHROUGH HERE: https://youtu.be/FwNe-oPYZHY

### STEP-BY-STEP DEPLOYMENT GUIDE

Step 1: Create IAM Role for EC2 and S3 Logging
1) Create an IAM role for EC2 named statemanager-role.
2) Attach AmazonSSMManagedInstanceCore and AmazonS3FullAccess.

Step 2: Launch Managed EC2 Instance
1) Launch an Amazon Linux EC2 instance named statemanager-instance.
2) Allow inbound HTTP (Port 80) access and attach statemanager-role.

Step 3: Create an S3 Bucket for Execution Logs
1) Navigate to Amazon S3 > Create bucket and create a globally unique bucket (e.g., statemanager-s3-140023390772-bucket).
2) Inside the bucket, create a folder/prefix named ec2-logs.

Step 4: Create a State Manager Association
1) Navigate to Systems Manager > State Manager > Create association.
2) Name the association httpd-install-association.
3) Under Document, select AWS-RunShellScript.
4) Under Parameters > Commands, enter:
```
#!/bin/bash
dnf install -y httpd
systemctl enable --now httpd
echo "<h1>Hello Cloud Learners</h1>" > /var/www/html/index.html
curl http://localhost
```

5) Under Target selection, manually select statemanager-instance.
6) Under Specify schedule, choose On schedule using the Rate schedule builder set to run every 30 minutes.
7) Under Output options, check Enable writing output to S3, specify your S3 bucket name, and set ec2-logs as the S3 key prefix.
8) Click Create association and wait for the status to transition from Pending to Success.

Step 5: Simulate Configuration Drift and Test Auto-Remediation
1) Connect to statemanager-instance via Systems Manager > Session Manager.
2) Stop and uninstall Apache HTTPD to simulate configuration drift:
```
sudo systemctl status httpd
sudo systemctl stop httpd
sudo dnf remove httpd -y
```

3) Return to Systems Manager > State Manager, select httpd-install-association, and click Apply association now (to trigger immediate remediation without waiting 30 minutes).
4) Re-verify in your Session Manager terminal or browser that Apache HTTPD has been automatically reinstalled and started.

Step 6: Inspect Execution Logs in S3
Navigate to your S3 bucket (ec2-logs prefix) and download the stdout and stderr output files to review remediation logs.


## MODULE 4: AUTOMATE OS VULNERABILITY SCANNNING & PATCHING WITH AWS SYSTEMS MANAGER PATCH MANAGER

AWS Systems Manager Patch Manager automates the process of scanning and patching operating systems (Amazon Linux, Ubuntu, Windows, macOS) against approved Patch Baselines at zero additional cost for EC2 instances. Using AWS-RunPatchBaseline under the hood, Patch Manager identifies missing security updates, generates compliance dashboards, and installs patches during controlled maintenance windows.

#### ACCESS PROJECT MATERIALS
#### PDF GUIDE: [AWS SYSTEMS MANAGER PATCH MANAGER.pdf](https://github.com/user-attachments/files/35067287/AWS.SYSTEMS.MANAGER.PATCH.MANAGER.pdf)
#### WATCH VIDEO WALKTHROUGH HERE: https://youtu.be/VKB28s_jMe8

### STEP-BY-STEP DEPLOYMENT GUIDE

Step 1: Create IAM Role for Patch Manager
1) Create an IAM role for EC2 named patchmanager-role.
2) Attach the following AWS managed policies:
   AmazonSSMManagedInstanceCore
   AmazonSSMFullAccess
   AmazonSSMPatchAssociation

Step 2: Launch Managed EC2 Instance
1) Launch an Amazon Linux EC2 instance named patchmanager-instance.
2) Allow inbound HTTP (Port 80) traffic and attach patchmanager-role.
3) Verify the instance is listed in Systems Manager > Fleet Manager.

Step 3: Simulate an Outdated Package Vulnerability
1) Connect to patchmanager-instance via Systems Manager > Session Manager.
2) List available package versions and downgrade bind-utils to introduce a detectable baseline discrepancy:
```
sudo dnf list --showduplicates bind-utils
sudo dnf install bind-utils-32:9.18.49-1.amzn2023.0.1
```

Step 4: Scan for Security Vulnerabilities (Scan Mode)
1) Navigate to Systems Manager > Patch Manager and click Start with an overview (or Patch now).   
2) Under Basic configuration > Patching operation, select Scan.
3) Under Instances to patch, select Patch only the target instances I specify, manually select patchmanager-instance, and click Patch now.
4) Once the scan completes, navigate to the Compliance reporting tab in Patch Manager.
5) Confirm that the instance is flagged as Non-compliant and inspect the Security non-compliant count to identify the outdated package.

Step 5: Remediate Vulnerabilities Automatically (Scan and Install Mode)
1) Return to Patch Manager > Patch now.
2) Set Patching operation to Scan and install and set Reboot option to Reboot if needed.
3) Manually target patchmanager-instance and click Patch now.
4) After patching and reboot complete, check Compliance reporting to verify the instance status has transitioned to Compliant.
5) Navigate to Systems Manager > Run Command > Command history to observe the underlying AWS-RunPatchBaseline execution logs.

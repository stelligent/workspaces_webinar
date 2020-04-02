# AWS Workspaces

The code in this repo is meant to be used as an educational/informational tool and is not intended for production deployment/use without some further refinements.

## Prerequisites

An AWS account and the AWS CLI installed and configured to use said account.

## Scripts

Here is a listing of the scripts/templates included in this repo and a brief description of what they do.

* `cloudforamtion/corporate-vpc.yaml` - This CFN template creates a "mock" corporate infrastructure stack with a Microsoft AD.  There is manual configuration required once this stack is stood up and those steps are listed below.
* `cloudformation/workspace-vpc.yaml` - This CFN template creates a VPC and "peers" it to the VPC created in corporate-vpc.yaml.  It also makes all the necessary route and security group updates to allow for file sharing with the AWS Workspaces.  There are manual steps requried as well which are outlined below.
* `scripts/create-workspace.yaml` - this script is a template intended to be modified and used to bulk load the creation of workspaces for multiple users.  For example, if delivered a list of users from an existing AD, once could easily iterate on this script while running it in parallel to create those workspaces.


## Setup

This section will detail out all the steps required to stand up this demo for use.  You must create the corporate stack first, as the second stack requires resources created by the first stack to complete.

### Create Mock Corporate Infrastructure

The first stack is a "mock" of an existing corporate infrastructure that will include a Microsoft AD and a file share on an EC2 instance.  The EC2 instance is also required to administer the AD so the instance includes the necessary software to do so.

1.  You need your IP address, so google `what is my ip address`.  You need this to create the first stack and limit the ability to RDP into the box to your IP Address only.
2.  Create the first stack using `cloudformation/corporate-vpc.yaml` passing in the IP address from Step 1.  Remember the stack name as you will need it when creating the second stack.
3.  Enjoy beverage of choice while you wait ~25 mins.

#### Configure EC2

Now that the instance is available we need to configure a few things for use, namely add uses to the AD and share a folder on the drive.

##### Add Users to AD // TODO: Automation opportunity

1. Grab the public IP address for the newly created instance and RDP into it using `admin@corp.company.com`.  The password is the microsoft default and is the `Default` parameter value in the `cloudformation/corporate-vpc.yaml` file.  You must RDP into this instance using an admin that is part of the AD that was just set up.
2. Search for `Active Directory Users and Computers` and run this program.
3. Navigate to `corp.company.com->corp->Users` and add 1..n users you wish.  These users will be the ones that you log into workspaces with eventually.
4. Navigate to `AWS Delegated Groups->AWS Delegated Administrators` and add all the users created in step 3 above to this group.

##### Configure File Share //TODO: Automation opportunity

1. Launch Windows Explorer and navigate to the `C:` drive.
2. Create a new folder called `fileshare` or whatever you want.  Note the folder name and the internal IP address of the EC2 instance.  You will need both when you launch your AWS Workspace later.
3. Create a text file in here and name it whatever you want.  Once we launch AWS Workspaces, we will connect to this folder and you should see this file.
4. Right click on this new folder and share it with `AWS Delegated Administrators` group.

### Create Workspaces VPC

The second stack, is a VPC for the AD Connector to reside in.

1. Create the second stack using `cloudformation/workspace-vpc.yaml` passing in the stack name you used when creating the first stack.
2. Enjoy another refreshing beverage of your choice, but it should only be ~10 mins or so.

#### Create AD Connector

There is no CFN/CLI/CDK support for AD Connector, so you must get your hands dirty and configure it through the AWS Console.

1.  Log into the AWS console and navigate to `Services->Directory Service->Directories`.
2.  Click on `Set up Directory`.  You should see an existing `corp.company.com` directory.  This is the Microsof AD that was set up when you created the first stack.  We are configing an AD Connector in a different VPC that will connect to this one.
3.  Select `AD Connector` and click `Next`.
4.  I'm cheap, so pick `Small` the click `Next`.
5.  Select the VPC created in the second stack.  It should have a name that includes **WorkspaceInfrastructure** in it.
6.  Select the two **Private** subnets from the two drop down lists.  Whether they are public or private should be reflected in their name.
7.  Click `Next`.
8.  Fill out the information
    * Directory DNS Name: corp.company.com (assuming you didn't override it when creating the stack)
    * DNS IP Addresses: Get these values from the Microsoft AD Directory Service that was configured with the first stack.  If you click on the details in the console, you will see them listed.  You will need both.
    * Service Account Username: Admin (I know but...)
    * Service Account Password: _get from template (default)_
9. Click `Next` and any other buttons to start it creating.
10. After a few minutes, you should see the status turn from a blue _Creating_ to a green _Active_.

Now we are ready to create a workspace and bind it to the AD Connector.

#### Create AWS Workspace

We have our corporate infrastructure in place, we created our VPC for the AD Connector and bound it to the Microsof AD in the corporate infrastruction, now we are ready to create a workspace.

1. Log into the AWS Console and navigate to `Services->Workspaces`.
2. Click `Launch Workspaces`.
3. Select the AD Connector you created (not the Microsoft AD!).
4. Select the same two **Private** subnets you chose when creating the AD connector.
5. Select `No` for both **Enable Self Service Permissions** and **Enable Amazon WorkDocs**
6. Click `Show All Users`.  There will only be a few.  You should see all the users you created when configuring Microsoft AD while logged into the EC2 instance created by the first stack.
7. Select the user(s) you want to create this workspace for and click `Next Step`.
8. Again, I'm cheap so pick a free bundle then click `Next Step`.
9. Keep the defaults and click `Next Step`.
10. Click `Launch`.
11. Sit back and enjoy another refresing beverage of your choice (better be careful depending on what you choose as a beverage...;) ) as workspace creating is ~20 minutes.

Once the workspace shows `AVAILABLE` you are ready to log in.

#### Log into the new AWS Workspace

You can use the `Invite User` functonality from the AWS Console if you wish, or you can just pull what you need for the console itself.  I'm lazy, impatient and cheap so I just use the console...;)

1.  Download the client of choice from `https://clients.amazonworkspaces.com/`
2.  Look at the workspace details and you will see a registration code, copy that to your clip board.
3.  Launch the AWS Workspace client, enter the registration code and log in using the user the workspace was created for.  It will be the username and password you used when you configured the user in AD back when you launched and configured the Microsoft AD as part of the corporate infrastructure.
4.  Once the workspace starts you should see your desktop.
5.  Now, using the internal IP address and folder name, map a network drive to it, and you should see your file you created back when setting up the file share.

Thats it and thanks for taking the time to run through this.  I hope you found it educational and informative.

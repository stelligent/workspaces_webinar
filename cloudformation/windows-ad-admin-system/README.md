This stack will spin up an EC2, that will automatically be added to the Active Directory spun up earlier.

Pre-requisite: Active directory stack must already be spun up before starting this stack (there are dependancies)

The following have to be added manually to the stack:
- Active Directory Domain Name (URL)
- Active Directory ID
- IP Addresses (Two)
- Subnet of the Active Directory (Any One)

Once the EC2 spins up, to connect to it, do the following:
- Go to S3 bucket and search for a new S3 bucket (with the stack's name) that has the PEM file in it
- Using the PEM file decrypt the windows servers password
- Remotely log in to the EC2 with the username "admin@<Active Directory Domain Name (URL)> and the password

To add users to the active directory
- Go to 'This PC' and check the properties to verify the connection to the Active Directory Domain Name
- Open Active Directory Users 
- Add a user

Work Remaining for 3/24/2020 are the following
- Programmatically add a user to Active Directory
- Parameterize the various hardcoded values in this template

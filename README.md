# Packer, GCP & Terraform

The scripts in this repository will create a gcp image with terraform installed on it, using packer.

After the image is created, you can start a server up based off of the image.  Look at Google documentation if this is not familiar to you.

In order to use, you will need an accounts.json file.  Information can be found here: https://cloud.google.com/iam/docs/creating-managing-service-account-keys

I assume you already have packer binary installed on your local machine.  Info here: https://www.packer.io/intro/getting-started/install.html

# Scripts and Files

terraform_install_centOS.json -- json file for packer.  installs using centOS.

terraform_install_ubuntu.json -- json file for packer.  installs ubuntu os.

terraform_install_debian9.json -- json file for packer that installs debian OS

install_files/install-terraform.sh -- main shell script that updates the OS image & installs Terraform

# Pre Requisites
- you need to setup an accounts.json file 

# Getting Started
Once you have downloaded this repo, simply run `packer build terraform_install_X.sh"`

Watch the output - you should see a message "A disk image was created: terraform-<OS>-YYYY-MM-DD-"

Example Output:
```
==> Builds finished. The artifacts of successful builds are:
--> googlecompute: A disk image was created: terraform-debian9-2019-07-16-015434
```
You can now use that image to start up a server with terraform ready to run.  
Confirm by starting the server and running terraform --version. 


# Updates 7/16/2019
- updated OS images to the latest
- added support for debian (Google's default image)
- updated to latest Terraform version (0.12.4)

# TODO
- Test downloading from gcs


# Helper Script
To speed up CLI testing, here is a simple script that you can use to start instances
```
name=$1
imageName=$2
zone=us-east4-c
projectID=
echo "to run pass in instance name (like test1) and imageName from output of packer run"

gcloud compute --project=$projectID instances create $name --zone=${zone} --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=<$$CHANGE> --scopes=<$CHANGE>--image=$imageName --image-project=<C$HANGE> --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$name
```
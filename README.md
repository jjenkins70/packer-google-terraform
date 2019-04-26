# Packer, GCP & Terraform

The scripts in this repository will create a gcp image with terraform installed on it, using packer.

After the image is created, you can start a server up based off of the image.  Look at Google documentation if this is not familiar to you.

In order to use, you will need an accounts.json file.  Information can be found here: https://cloud.google.com/iam/docs/creating-managing-service-account-keys

I assume you already have packer binary installed on your local machine.  Info here: https://www.packer.io/intro/getting-started/install.html

# Scripts and Files

terraform_install_centOS.json -- json file for packer.  installs using centOS.

terraform_install_ubuntu.json -- json file for packer.  installs ubuntu os.

install_files/install-terraform.sh -- main shell script that updates the OS image & installs Terraform

# How
Once you have downloaded this repo, simply run "packer build terraform_install_X.sh"  
Watch the output - you should see a message "A disk image was created: terraform-<OS>-YYYY-MM-DD-"
You can now use that image to start up a server with terraform ready to run.  Confirm by starting the server and running terraform --version.



# TODO
- Test on google's default image
- Test downloading from gcs


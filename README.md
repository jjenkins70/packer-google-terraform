# Packer, GCP & Terraform

The scripts in this repository will create a gcp image with terraform installed on it, using packer.

In order to use, you will need an accounts.json file.  Information can be found here: https://cloud.google.com/iam/docs/creating-managing-service-account-keys

# TODO
- Test on google's default image
- Test downloading from gcs


# Scripts and Files

terraform_install_centOS.json -- json file for packer.  installs using centOS.

terraform_install_ubuntu.json -- json file for packer.  installs ubuntu os.

install_files/install-terraform.sh -- main shell script that updates the OS image & installs Terraform





#!/bin/sh

#This is to download latest version & upload to the GCS bucket

#Variable
gcs_bucket=jj-install-bucket
#consulVersion=1.4.4 #consul version
terVersion=0.11.13

#Downlaod Terraform
wget https://releases.hashicorp.com/terraform/${terVersion}/terraform_${terVersion}_linux_amd64.zip

echo "Rename terraform "
mv terraform_${terVersion}_linux_*.zip terraform.zip

for name in terraform.zip
do
	gsutil cp $name gs://${gcs_bucket}/install_files/
	#rm $name
done

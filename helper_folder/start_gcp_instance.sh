name=$1
imageName=$2
zone=us-east4-c
echo "to run pass in instance name (like test1) and imageName from output of packer run"

gcloud compute --project=jeremiah-sbx instances create $name --zone=${zone} --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=1041296306970-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image=$imageName --image-project=jeremiah-sbx --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$name

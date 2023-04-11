Child module for VM deployment. Consist of:
  1. main.tf
  2. variables.tf
  3. provider.tf

Source: ".main.tf"


Outputs
  If output required - to be requested via:
  output "<value>_outputs" {
  value = module.<module name>
}

Following variables are declared via TF_VAR_ in variables.tf:
  token
  cloud_id
  folder_id
  zone

Token has tp be re-generated every 12 hours

Helper:

Following env variables to be set up:
  $Env:TF_VAR_token = "<put value>"; 
  $Env:TF_VAR_cloud_id = "<put value>";
  $Env:TF_VAR_folder_id = "<put value>";
  $Env:TF_VAR_zone = "<put value>";
  $Env:TF_VAR_s3_key = "<put value>";
  $Env:TF_VAR_s3_secret = "<put value>";

Initializing through terraform init -backend-config "access_key=$Env:TF_VAR_s3_key" -backend-config "secret_key=$Env:TF_VAR_s3_secret" -upgrade
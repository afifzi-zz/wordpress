# wordpress
Wordpress deployment on gke

# Dependencies
1. Terraform version: 0.11.11

# How to install
1. Clone this repo
2. Put your GCP Service Account inside directory sa/sa.json
3. Edit variable.tf, put your gcp project id and save
variable "gcp_project_id" {
  default = "xxxx"
}

# How to run
1. Run script blog-up.sh

# How to resize
1. Run script blog-resize.sh 3
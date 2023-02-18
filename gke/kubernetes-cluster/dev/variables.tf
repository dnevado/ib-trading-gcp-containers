variable "project_id" {
    type = string
    default = "api-project-786272790820" 
}
variable "region" {
    type = string
    default ="europe-west9" #  "europe-southwest1"  # MILAN - MADRID 

}
variable "zone" {
    type = string
    default = "europe-west9-a" 

}
// ["dev", "prod"]
variable "env" {
    type    = string
    default = "dev"
}
variable "email_service_account" {
    type    = string
    default = "786272790820-compute@developer.gserviceaccount.com"
}
variable "email_cloudbuild_service_account" {
    type    = string
    default = "786272790820@cloudbuild.gserviceaccount.com"
}


variable "gke_username" {
  default     = "dnevado"
  description = "gke_username"
}
 
variable "gke_password" {
  default     = "10203040"
  description = "gke_password"
}
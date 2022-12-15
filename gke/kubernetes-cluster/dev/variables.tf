variable "project_id" {
    type = string
    default = "api-project-786272790820" 
}
variable "region" {
    type = string
    default = "europe-southwest1" 

}
variable "zone" {
    type = string
    default = "europe-southwest1-a" 

}
// ["dev", "prod"]
variable "env" {
    type    = string
    default = "dev"
}
variable "email_service_account" {
    type    = string
    default = "dnevado@gmail.com"
}
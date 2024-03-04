variable "gcp_project" {
    type = string
    description = "GCP Project to provision the VM in"
}

variable "gcp_region" {
    type = string
    description = "GCP Region to provision the VM in"
}

variable "ssh_public_key" {
  type = string
  description = "SSH public key to inject into the VM"
}

variable "service_account" {
    type = string
    description = "Service account in the project to assign to the VM"
}

variable "name" {
    type = string
    description = "Name of the VM"
}

variable "machine_type" {
    type = string
    description = "VM machine type. Must be one that support GPU"
    default = "n1-standard-4"
}

variable "accelerator_type" {
    type = string
    description = "Accelerator type"
    default = "nvidia-tesla-t4"
}

variable "boot_image_size" {
    type = number
    description = "Size of the boot image. Make sure it has enough space to pull models"
    default = 30
}

variable "ip_cidr_range" {
    type=string
    description="List of The range of internal addresses that are owned by this subnetwork."
    default="172.18.0.0/24"
}

variable "ssh_port" {
    type = number
    description = "Override the SSH port number"
    default = 22
}

variable "application_port" {
    type = number
    description = "Allow access to this port. Set to 0 to disable"
    default = 0
}

variable "limit_additionl_port" {
    type = bool
    description = "Limit access to the additional port to the provisioning source IP"
    default = false
}

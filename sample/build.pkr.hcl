
packer {
    required_plugins {
        googlecompute = {
            version = "~> v1.0"
            source = "github.com/hashicorp/googlecompute"
        }
    }
}

variable "project_id" {
    type = string
}

variable "network_project_id" {
    type = string
}

variable "subnetwork" {
    type = string
}

variable "zone" {
    type = string
}

variable "project_sa" {
    type = string
}

source "googlecompute" "a-sample" {
    project_id = var.project_id    
    network_project_id = var.network_project_id
    subnetwork = var.subnetwork
    zone = var.zone
    source_image_family = "centos-7"    
    image_name = "a-sample"
    image_description = "Sample image with key RPM installed"
    ssh_username = var.project_sa
    tags = ["packer"]
    impersonate_service_account = var.project_sa
    image_licenses = ["projects/vm-options/global/licenses/enable-vmx"]
    machine_type = "e2-standard-4"
    state_timeout  = "20m"
    use_internal_ip = true
    omit_external_ip = true
    use_iap = true
    use_os_login = true    
}

build {
    sources = ["sources.googlecompute.a-sample"]    
    
    provisioner "ansible" {
        playbook_file = "playbook.yml"
        user = var.project_sa
        ansible_env_vars = [
           "ANSIBLE_HOST_KEY_CHECKING=False", 
           "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s'", 
           "ANSIBLE_NOCOLOR=True",
           "ANSIBLE_TIMEOUT=30"
        ]        
    }
}

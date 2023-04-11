#---------------------------------------
# Compute variables
#---------------------------------------
variable "vm_cores" {
  description = "how much cores for the VM"
  type        = string
  default     = "2"
}

variable "vm_ram" {
  description = "how much RAM for the VM"
  type        = string
  default     = "2"
}

variable "OS_drive" {
  description = "default OS drive"
  type        = string
  default     = "30"
}

variable "login" {
  description = "Student Login"
  type        = string
}

variable "chapter" {
  description = "Student Login"
  type        = string
}

variable "lesson" {
  description = "Student Login"
  type        = string
}

variable "image_id" {
  description = "Image ID for VM deployement"
  type        = string
  default     = "fd80qm01ah03dkqb14lc"
}

variable "user" {
  description = "Student Login"
  type        = string
  default     = ""
}

variable "meta_data" {
  description = "Meta Data For authentication"
  type        = string
  default     = ""

  sensitive = true
}

variable "subnet_id" {
  description = "SSH Public Key"
  type        = string
  default     = ""
}

variable "nat" {
  description = "PIP"
  type        = bool
  default     = true
}

variable "policy" {
  description = "sheduling policy"
  type        = bool
  default     = true
}

variable "network_zone" {
  description = "Yandex.Cloud network availability zones"
  type        = string
  default     = "ru-central1-a" #"ru-central1-a"
}


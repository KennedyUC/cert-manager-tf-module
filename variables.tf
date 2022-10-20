variable "create_namespace" {
    type = bool
    default = False
    description = "Specify the whether namespace is created by Helm"
}

variable "enable_atomic" {
    type = bool
    default = False
    description = "Specify the whether atomic is enabled in Helm"
}
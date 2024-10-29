variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    function_app = {
      name       = "func"
      max_length = 60
    }
    storage_account = {
      name       = "sa"
      max_length = 24
    }
    service_plan = {
      name       = "asp"
      max_length = 60
    }
    resource_group = {
      name       = "rg"
      max_length = 60
    }
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 0 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 0 to 100."
  }
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "func"
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "dev"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "location" {
  description = "Location where the function app will be created"
  type        = string
}

variable "storage_account_tier" {
  description = "The Tier to use for this storage account"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "The Replication Type to use for this storage account"
  type        = string
  default     = "LRS"
}

variable "sku" {
  description = "The SKU for the function app hosting plan"
  type        = string
  default     = "Y1"
}

variable "app_settings" {
  description = "Environment variables to set on the function app"
  type        = map(string)
  default     = {}
}

variable "functions_extension_version" {
  description = "The version of the Azure Functions runtime to use"
  type        = string
  default     = "~4"
}

variable "https_only" {
  description = "If true, the function app will only accept HTTPS requests"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "If true, the function app will be accessible from the public internet"
  type        = bool
  default     = true
}

variable "site_config" {
  description = <<-EOF
    object({
      always_on        = If this Linux Web App is Always On enabled. Defaults to false.
      app_command_line = The App command line to launch.
      app_scale_limit  = The number of workers this function app can scale out to. Only applicable to apps on the Consumption and Premium plan.
      application_stack = optional(object({
        docker = optional(object({
          image_name        = The name of the Docker image to use.
          image_tag         = The image tag of the image to use.
          registry_url      = The URL of the docker registry.
          registry_username = The username to use for connections to the registry.
          registry_password = The password for the account to use to connect to the registry.
        }))
        dotnet_version              = optional(string)
        use_dotnet_isolated_runtime = optional(bool)
        java_version                = optional(string)
        node_version                = optional(string)
        python_version              = optional(string)
        powershell_core_version     = optional(string)
        use_custom_runtime          = optional(bool)
      }))
      container_registry_managed_identity_client_id = The Client ID of the Managed Service Identity to use for connections to the Azure Container Registry.
      container_registry_use_managed_identity       = Should connections for Azure Container Registry use Managed Identity.
      cors = optional(object({
        allowed_origins     = list(string)
        support_credentials = optional(bool)
      }))
      health_check_path = The path to be checked for this function app health.
      http2_enabled     = Specifies if the HTTP2 protocol should be enabled. Defaults to false.
      ip_restriction = optional(list(object({
        ip_address = The CIDR notation of the IP or IP Range to match.
        action     = The action to take. Possible values are Allow or Deny. Defaults to Allow.
      })))
      minimum_tls_version = The configures the minimum version of TLS required for SSL requests. Defaults to '1.2'
    })
  EOF
  type = object({
    always_on        = optional(bool)
    app_command_line = optional(string)
    app_scale_limit  = optional(number)
    application_stack = optional(object({
      dotnet_version              = optional(string)
      use_dotnet_isolated_runtime = optional(bool)
      java_version                = optional(string)
      node_version                = optional(string)
      powershell_core_version     = optional(string)
      use_custom_runtime          = optional(bool)
    }))
    cors = optional(object({
      allowed_origins     = list(string)
      support_credentials = optional(bool)
    }))
    health_check_path = optional(string)
    http2_enabled     = optional(bool)
    ip_restriction = optional(list(object({
      ip_address = string
      action     = string
    })))
    minimum_tls_version = optional(string)
  })
  default = {}
}

variable "identity_ids" {
  description = <<EOT
    Specifies a list of user managed identity ids to be assigned.
  EOT
  type        = list(string)
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "os_type" {
  description = "The operating system type of the function app"
  type        = string
  default     = "Linux"
}
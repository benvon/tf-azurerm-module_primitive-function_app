// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.location
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  maximum_length          = each.value.max_length
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = local.resource_group_name
  location = var.location

  tags = merge(var.tags, { resource_name = module.resource_names["resource_group"].standard })
}

module "storage_account" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/storage_account/azurerm"
  version = "~> 1.0"

  storage_account_name = local.storage_account_name
  resource_group_name  = module.resource_group.name

  location = var.location

  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type

  tags = merge(var.tags, { resource_name = module.resource_names["storage_account"].standard })

  depends_on = [module.resource_group]
}

data "azurerm_storage_account" "storage_account" {
  name                = local.storage_account_name
  resource_group_name = module.resource_group.name
  depends_on          = [module.storage_account]
}

module "app_service_plan" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/app_service_plan/azurerm"
  version = "~> 1.0"

  name                = local.service_plan_name
  resource_group_name = module.resource_group.name

  os_type = "Linux"

  location = var.location
  sku_name = var.sku

  tags = merge(var.tags, { resource_name = module.resource_names["service_plan"].standard })

  depends_on = [module.resource_group]
}

module "function_app" {
  source = "../.."

  function_app_name          = local.function_app_name
  service_plan_name          = local.service_plan_name
  storage_account_name       = local.storage_account_name
  storage_account_access_key = data.azurerm_storage_account.storage_account.primary_access_key

  location                      = var.location
  resource_group_name           = module.resource_group.name
  public_network_access_enabled = var.public_network_access_enabled

  app_settings                = var.app_settings
  functions_extension_version = var.functions_extension_version
  https_only                  = var.https_only
  site_config                 = var.site_config

  identity                        = var.identity == null ? null : var.identity
  key_vault_reference_identity_id = var.key_vault_reference_identity_id == null ? null : var.key_vault_reference_identity_id

  tags = merge(var.tags, { resource_name = module.resource_names["function_app"].standard })

  depends_on = [module.resource_group, module.storage_account, module.app_service_plan]
}

# module "role_assignment" {
#   source               = "terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm"
#   version              = "~> 1.0"
#   count                = var.identity == null ? 0 : 1
#   scope                = module.storage_account.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = module.function_app.principal_id

#   depends_on = [module.function_app]
# }

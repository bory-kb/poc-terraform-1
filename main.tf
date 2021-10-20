terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${var.resource_group_name_prefix}${var.project_name}"
  location = var.resource_group_location
  tags = {
    "key" = "tag_terraform"
  }
}

resource "azurerm_app_service_plan" "default" {
  name                = "plan-${var.project_name}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "default" {
  name                = "app-${var.project_name}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  app_service_plan_id = azurerm_app_service_plan.default.id
  site_config {

    dotnet_framework_version = "V4.0"
    scm_type                 = "LocalGit"

    cors {
      allowed_origins     = ["https://www.microsoft.com/ja-jp/"]
      support_credentials = "true"
    }

  }
  app_settings = {
    "test" = "value"
  }
  identity {
    type = "SystemAssigned"
  }
}
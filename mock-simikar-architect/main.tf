# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.79"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "dev" {
  name     = "poc-${var.resource_name}"
  location = var.location
}


resource "azurerm_app_service_plan" "dev" {
  name                = "plan-${var.resource_name}"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

  sku {
    tier = "Basic"
    size = "B1"
  }

}

resource "azurerm_app_service" "front" {
  name                    = "app-${var.resource_name}"
  location                = azurerm_resource_group.dev.location
  resource_group_name     = azurerm_resource_group.dev.name
  app_service_plan_id     = azurerm_app_service_plan.dev.id
  client_affinity_enabled = true



  site_config {
    default_documents = ["index.html"]
    # .net Core がうまいこと指定できない
    windows_fx_version = "DOTNETCORE|3.1"
    scm_type           = "None"
    ftps_state         = "FtpsOnly"
  }

  app_settings = {
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

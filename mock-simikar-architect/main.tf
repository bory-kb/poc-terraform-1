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
    default_documents = ["index.html", "Default.htm", "Default.html", "Default.asp", "index.htm", "iisstart.htm", "default.aspx", "index.php", "hostingstart.html"]
    # .net Core がうまいこと指定できない
    windows_fx_version = "DOTNETCORE|3.1"
    scm_type           = "None"
    ftps_state         = "FtpsOnly"
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = "${azurerm_application_insights.front.instrumentation_key}"
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"         = "~1"
    "SnapshotDebugger_EXTENSION_VERSION"              = "~1"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "~1"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

resource "azurerm_application_insights" "front" {
  name                = "appi-${var.resource_name}"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  application_type    = "web"
}

resource "azurerm_application_insights" "backendFunc" {
  name                = "appi-${var.resource_name}-api"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
  application_type    = "web"
}

resource "azurerm_storage_account" "funcStr" {

  name                = "strterraform20211202"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

  account_tier             = "standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "backendFunc" {
  name                = "func-${var.resource_name}"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

  app_service_plan_id        = azurerm_app_service_plan.dev.id
  storage_account_name       = azurerm_storage_account.funcStr.name
  storage_account_access_key = azurerm_storage_account.funcStr.primary_access_key

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = "${azurerm_application_insights.backendFunc.instrumentation_key}"
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"         = "~1"
    "SnapshotDebugger_EXTENSION_VERSION"              = "~1"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "~1"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
  }

}

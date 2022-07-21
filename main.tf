#terraform {
 # required_providers {
 #   azurerm={
 #    version ="2.44.0"
 #     source = "hashicorp/azurerm"
  #  }
  #}
#}

# provider "azurerm" {
 # features {
   # subscription_id ="*********************" 
 # }
  
#}
# Create a provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id = "${var.tenant_id}"
}

# create resource group
resource "azurerm_resource_group" "rg1" {
  name     = "vnettest"
  location = "${var.location}"

  tags = {
    "environment" = "Dev"
  }

}

# Here we define resources required for our application to run

resource "azurerm_app_service_plan" "appplan" {
  name                = "myappserviceplan"
  location            = "${var.locatiion}"
  resource_group_name = "${azurerm_resource_group.rg1.name}"
  sku {
    size = "S1"
    tier = "Standard"
  }

}
# create app service with dotnet 6.0 version

resource "azurerm_app_service" "appservice" {
  name                = "myappservice"
  location            = "${azurerm_resource_group.rg1.location}"
  app_service_plan_id = azurerm_app_service_plan.appplan.id
  resource_group_name = "${azurerm_resource_group.rg1.name}"

  site_config {
    dotnet_framework_version = "v6.0"
  }

}

# Create VNET with CIDR Range

resource "azurerm_virtual_network" "myvn" {
  name                = "${var.vnetname}"
  resource_group_name = "${azurerm_resource_group.rg1.name}"
  location            = "${azurerm_resource_group.rg1.location}"
  address_space       = ["192.16.0.0/16"]

}

# Create SUBNET 

resource "azurerm_subnet" "myvn_subnet" {
  name                 = "${var.snet_name}"
  resource_group_name  = "${azurerm_resource_group.rg1.name}"
  virtual_network_name = "${azurerm_virtual_network.myvn.name}"
  address_prefixes     = ["192.16.1.0/24"]

}

# create azure_mysql_databasedata (this is for secret database server)

resource "azurerm_mysql_server" "app_server" {
  name                         = "mydbsqlserver"
  resource_group_name          = "${azurerm_resource_group.rg1.name}"
  location                     = "${azurerm_resource_group.rg1.location}"
  version                      = "12.0"
  administrator_login          = "${var.sqladmin}"
  administrator_login_password = "${var.admpasswd}"
  ssl_enforcement_enabled      = true

  sku_name   = "GP_Gen5_4"
  storage_mb = 5120

  tags = {
    environment = "Dev"
  }
}
# Create secret DB server
resource "azurerm_mysql_database" "app_db" {
  name                = "myappdb"
  resource_group_name = "${azurerm_resource_group.rg1.name}"
  location            = "${azurerm_resource_group.rg1.location}"
  server_name         = azurerm_mysql_server.app_server.name
  depends_on = [
    azurerm_mysql_server.app_server
  ]

}

# create firewall for fixing access contrtolls
resource "azurerm_mysql_firewall_rule" "app_server_firewall_rule" {
  name                = "app_server_firewall_rule"
  resource_group_name = "${azurerm_resource_group.rg1.name}"
  server_name         = azurerm_mysql_server.app_server.name
  start_ip_address    = "${var.start_ip}"
  end_ip_address      = "${var.end_ip}"
  depends_on = [
    azurerm_mysql_server.app_server
  ]

}


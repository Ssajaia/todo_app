terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }

  backend "azurerm" {
    resource_group_name = "rg-todo-app"
    storage_account_name = "sttodoappstate"
    container_name       = "tfstate"
    key                  = "todo-app.tfstate"
  }
}

provider "azurerm" {
  features {}
}

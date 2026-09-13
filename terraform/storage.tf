# Storage account to hold the persistent SQLite database file via Azure Files.
resource "azurerm_storage_account" "data" {
  name                     = "st${replace(var.app_name, "-", "")}data"
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_share" "todo_data" {
  name               = "todo-data"
  storage_account_id = azurerm_storage_account.data.id
  quota              = 1 # GB - plenty for a SQLite file
}

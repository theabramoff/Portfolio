variable "resource_group_name" {
  type        = string
  description = "RG name in Sub 01"
  default     = "rg-az01-SQL-autoscaling-test"
}

variable "tags" {
  description = "The tags to associate with the resources"
  type        = map(string)

  default = {
    Description       = "Test for SQL autoscaling using LogicApp"
    OwnedBy           = "Abramov, Andrey"
    OwnerBackupPerson = "N/A"
  }
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "west europe"
}

variable "sql" {
  type        = string
  description = "common storage name"
  default     = "sql-az01-SQL-autoscaling-test"
}

variable "sqldb" {
  type        = string
  description = "SQL DBs"
  default     = "sqldb-az01-SQL-autoscaling-test-"
}

variable "logic" {
  type        = string
  description = "Logic Apps"
  default     = "logicapp-az01-SQL-autoscaling-test"
}
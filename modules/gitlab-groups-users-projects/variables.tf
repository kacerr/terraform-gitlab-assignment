variable "gitlab_token" {
  type = string
}

variable "gitlab_base_url" {
  type    = string
}


variable "groups" {
  type = map(object({ name = string, path = string, description = string }))
  default = {
    "example-group" = {
      name        = "example-group"
      path        = "path-to-example-group"
      description = "description of example group"
    }
    "example-group-2" = {
      name        = "example-group-2"
      path        = "path-to-example-group-2"
      description = "description of example group 2"
    }
  }
}


variable "users" {
  type = map(object({ name = string, username = string, email = string, groups = set(string) }))
  default = {
    "example-user" = {
      name        = "example-user"
      username = "example-user-name"
      email = "example-user@email.cz"
      groups = ["example-group", "example-group-2"]
    }
  }
}

variable "projects" {
  type = map(object({ name = string, group_name = string }))
  default = {
    "example-project" = {
      name        = "example-project"
      group_name = "example-group-2"
    }
  }
}
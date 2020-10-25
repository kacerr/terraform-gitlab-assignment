variable "gitlab_token" {
  type = string
}

variable "gitlab_base_url" {
  type    = string
  default = "http://localhost:8080/api/v4/"
}

variable "users" {
  type = map(object({ name = string, username = string, email = string, groups = set(string) }))
  default = {
    "user-1" = {
      name     = "user-1"
      username = "user-1-name"
      email    = "user-1@email.cz"
      groups   = ["red"]
    }
    "user-2" = {
      name     = "user-2"
      username = "user-2-name"
      email    = "user-2@email.cz"
      groups   = ["red"]
    }
    "user-3" = {
      name     = "user-3"
      username = "user-3-name"
      email    = "user-3@email.cz"
      groups   = ["red", "green"]
    }
    "user-4" = {
      name     = "user-4"
      username = "user-4-name"
      email    = "user-4@email.cz"
      groups   = ["green", "blue"]
    }
    "user-5" = {
      name     = "user-5"
      username = "user-5-name"
      email    = "user-5@email.cz"
      groups   = ["green", "blue"]
    }
    "user-6" = {
      name     = "user-6"
      username = "user-6-name"
      email    = "user-6@email.cz"
      groups   = ["red", "green", "blue"]
    }
    "user-7" = {
      name     = "user-7"
      username = "user-7-name"
      email    = "user-7@email.cz"
      groups   = ["green"]
    }
    "user-8" = {
      name     = "user-8"
      username = "user-8-name"
      email    = "user-8@email.cz"
      groups   = ["green"]
    }
    "user-9" = {
      name     = "user-9"
      username = "user-9-name"
      email    = "user-9@email.cz"
      groups   = ["red", "blue"]
    }
    "user-10" = {
      name     = "user-10"
      username = "user-10-name"
      email    = "user-10@email.cz"
      groups   = ["blue"]
    }
  }
}

variable "groups" {
  type = map(object({ name = string, path = string, description = string }))
  default = {
    "red" = {
      name        = "red"
      path        = "path-to-red"
      description = "description of red"
    }
    "green" = {
      name        = "green"
      path        = "path-to-green"
      description = "description of green"
    }
    "blue" = {
      name        = "blue"
      path        = "path-to-blue"
      description = "description of blue"
    }
  }
}

variable "projects" {
  type = map(object({ name = string, group_name = string }))
  default = {
    "1st red project" = {
      name       = "1st red project"
      group_name = "red"
    }
    "1st green project" = {
      name       = "1st green project"
      group_name = "green"
    }
  }
}




locals {
  users_from_file    = try(yamldecode(file("./users_extra.yaml")), {})
  merged_users       = merge(var.users, local.users_from_file)
  groups_from_file   = try(yamldecode(file("./groups_extra.yaml")), {})
  merged_groups      = merge(var.groups, local.groups_from_file)
  projects_from_file = try(yamldecode(file("./projects_extra.yaml")), {})
  merged_projects    = merge(var.projects, local.projects_from_file)
}


module "gitlab_users_and_groups" {
  source = "../modules/gitlab-groups-users-projects"

  gitlab_token    = var.gitlab_token
  gitlab_base_url = var.gitlab_base_url

  groups   = local.merged_groups
  users    = local.merged_users
  projects = local.merged_projects

}

output "debug" {
  value = module.gitlab_users_and_groups.debug
}

resource "local_file" "users_yaml" {
  filename = "./data/users.yaml"
  content  = yamlencode(var.users)
}

resource "local_file" "users_json" {
  filename = "./data/users.json"
  content  = jsonencode(var.users)
}

resource "local_file" "groups_yaml" {
  filename = "./data/groups.yaml"
  content  = yamlencode(var.groups)
}

resource "local_file" "groups_json" {
  filename = "./data/groups.json"
  content  = jsonencode(var.groups)
}

resource "local_file" "projects_yaml" {
  filename = "./data/projects.yaml"
  content  = yamlencode(var.projects)
}

resource "local_file" "projects_json" {
  filename = "./data/projects.json"
  content  = jsonencode(var.projects)
}

resource "gitlab_group" "groups" {
  for_each    = var.groups
  name        = each.value["name"]
  path        = each.value["path"]
  description = each.value["description"]
}

resource "gitlab_user" "users" {
  for_each = var.users
  name     = each.value["name"]
  username = each.value["username"]
  email    = each.value["email"]
  # At least one of either password or reset_password must be defined
  reset_password = true
}

locals {
  membership = flatten([for user_name, user in var.users:
                flatten([for group_name in user["groups"]:
                {
                  "user_name" = user_name
                  "group_name" = group_name
                }
                ])
  ])
}

resource "gitlab_group_membership" "group_memberships" {
  for_each =  { for idx, record in local.membership : idx => record }
  group_id     = gitlab_group.groups[each.value.group_name].id
  user_id      = gitlab_user.users[each.value.user_name].id
  access_level = "maintainer"
  # expires_at   = "2020-12-31"
}


resource "gitlab_project" "projects" {
  for_each = var.projects
  name     = each.value["name"]
  namespace_id = gitlab_group.groups[each.value["group_name"]].id
}

output "debug" {
  value = {
    "membership" = local.membership
    "groups" = gitlab_group.groups
    "users" = gitlab_user.users
  }

}


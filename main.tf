terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    railway = {
      source  = "terraform-community-providers/railway"
      version = "~> 0.2.0"
    }
  }
}

locals {
  username = data.coder_workspace.me.owner
}

provider "coder" {}

data "coder_provisioner" "me" {}

data "coder_workspace" "me" {}

resource "coder_agent" "main" {
  arch = "amd64"
  os   = "linux"

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }
}

provider "railway" {}

resource "railway_project" "coder_workspace" {
  name = "coder-${lower(data.coder_workspace.me.owner)}-${lower(data.coder_workspace.me.name)}"
}

resource "railway_service" "workspace" {
  count          = data.coder_workspace.me.start_count
  name           = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  project_id     = railway_project.coder_workspace.id
  source_repo    = "matifali/coder-railway"
  root_directory = "build"
}

resource "railway_variable" "coder_agent_init_script" {
  count          = data.coder_workspace.me.start_count
  service_id     = railway_service.workspace[0].id
  environment_id = railway_project.coder_workspace.default_environment.id
  name           = "CODER_AGENT_INIT_SCRIPT"
  value          = base64encode(coder_agent.main.init_script)
}

resource "railway_variable" "coder_agent_token" {
  count          = data.coder_workspace.me.start_count
  service_id     = railway_service.workspace[0].id
  environment_id = railway_project.coder_workspace.default_environment.id
  name           = "CODER_AGENT_TOKEN"
  value          = coder_agent.main.token
}

module "code-server" {
  source   = "https://registry.coder.com/modules/code-server"
  agent_id = coder_agent.main.id
}

module "filebrowser" {
  source        = "https://registry.coder.com/modules/filebrowser"
  agent_id      = coder_agent.devbox.id
  folder        = "/home/coder"
  database_path = ".config/filebrowser.db"
}

module "jetbrains_gateway" {
  count          = var.jetbrains_module ? 1 : 0
  source         = "https://registry.coder.com/modules/jetbrains-gateway"
  agent_id       = coder_agent.devbox.id
  agent_name     = "main"
  folder         = "/home/coder/workspace/app"
  jetbrains_ides = ["IU", "GO", "WS", "PY", "PC", "PS", "CL", "RM", "DB", "RD"]
}

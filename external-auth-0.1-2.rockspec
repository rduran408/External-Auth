package = "external-auth"
version = "0.1-2"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/aunkenlabs/kong-external-authx",
  tag = "0.1"
}
description = {
  summary = "Kong plugin to authenticate requests using http services.",
  license = "MIT",
  homepage = "https://github.com/aunkenlabs/kong-external-auth",
  detailed = [[
      Kong plugin to authenticate requests using http services.
  ]]
}
dependencies = {
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.external-auth.handler"] = "src/handler.lua",
    ["kong.plugins.external-auth.schema"] = "src/schema.lua",
    ["kong.plugins.external-auth.daos"] = "daos.lua",
    ["kong.plugins.external-auth.migrations.init"] = "migrations/init.lua",
    ["kong.plugins.external-auth.migrations.000_base_external_auth"] = "migrations/000_base_external_auth.lua"
  }
}

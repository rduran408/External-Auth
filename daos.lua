local typedefs = require "kong.db.schema.typedefs"

return {
  external_auth_table = {
    primary_key = { "id" },
    name = "external_auth_table",
    cache_key = { "token" },
    fields = {
      { id = typedefs.uuid },
      { created_at = typedefs.auto_timestamp_s },      
      { token = {type = "string", required = true, unique = true}},
      { auth_header = {type = "string", required = false}},
      { jwt = {type = "string", required = false}},
      { xlc_headers = { type = "string", required = false, auto = false }, }
    },
  },
}
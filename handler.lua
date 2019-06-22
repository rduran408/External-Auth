local BasePlugin = require "kong.plugins.base_plugin"
local http = require "resty.http"
local kong = kong
local ExternalAuthHandler = BasePlugin:extend()
local json = require "json"
local ngx = ngx
local concat = table.concat
local random = math.random

 mlcache = require "resty.mlcache"


local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

local function fetch_uuid(uuid,jwt)
   return jwt
end  

function ExternalAuthHandler:new()
  ExternalAuthHandler.super.new(self, "external-auth")
end

function ExternalAuthHandler:init_worker()
       cache, err = mlcache.new("my_cache", "prometheus_metrics", {
            lru_size = 500,    -- size of the L1 (Lua VM) cache
            ttl      = 3600,   -- 1h ttl for hits
            neg_ttl  = 30,     -- 30s ttl for misses
            ipc_shm = "prometheus_metrics",
        })

       if cache then
         kong.log("$$$ CACHE INIT")
       end

end

function ExternalAuthHandler:header_filter(conf)
  local headers = kong.response.get_headers()

    for i, v in pairs(headers) do
      --print( string.format("$$$ HEADER_FILTER %s %s", i, v ))
    end

end



function ExternalAuthHandler:body_filter(conf)
  --ExternalAuthHandler.super.body_filter(self)


    local ctx = ngx.ctx
    local chunk, eof = ngx.arg[1], ngx.arg[2]

    ctx.rt_body_chunks = ctx.rt_body_chunks or {}
    ctx.rt_body_chunk_number = ctx.rt_body_chunk_number or 1

    kong.log("$$$ BODY_FILTER STATUS"..kong.response.get_status())
    if eof then
      local chunks = concat(ctx.rt_body_chunks)
      
      ngx.arg[1] = chunks
      print("$$$ EOF BODY_FILTER from PLUGIN"..chunks)

      local headers = kong.response.get_headers()

      for i, v in pairs(headers) do
        print( string.format("$$$ BODY_FILTER HEADER %s %s", i, v ))
      end

      if kong.response.get_status() == 200 then
          kong.log("$$$ BODY FILTER INSERTING NEW ENTRY TO TABLE")
          local authresp = json:decode( chunks)
          local headers = kong.request.get_headers()
  


          local uuid = uuid()
          local jwtToken = authresp._embedded.jwt.access_token
          ok,err = cache:get(uuid,nil,fetch_uuid,uuid, jwtToken)
          if not ok then
              kong.log("$$$ CACHE GET failed")
           end

          ttl,err,value = cache:peek(uuid)
          if not err then
              kong.log("$$$$ CACHE PROBE ", value)
          end

         if not ok then
           kong.log.err("Error inserting token to cache"..err)
         end
       end
     else
        print("$$$ PLUGIN RECEIVED CHUNK "..chunk)
        ctx.rt_body_chunks[ctx.rt_body_chunk_number] = chunk
        ctx.rt_body_chunk_number = ctx.rt_body_chunk_number + 1
        ngx.arg[1] = nil
     end

end


function ExternalAuthHandler:access(conf)
  ExternalAuthHandler.super.access(self)

end

ExternalAuthHandler.PRIORITY = 900

return ExternalAuthHandler

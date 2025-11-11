require "log"
require "json"
require "./d1/configuration"
require "./d1/types"
require "./d1/response"
require "./d1/api"
require "./d1/context"

# API for Cloudflare D1 databases.
module D1
  VERSION = "0.1.0"
  Log     = ::Log.for("d1")
end

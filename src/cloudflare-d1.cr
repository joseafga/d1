require "log"
require "json"
require "./cloudflare/d1/configuration"
require "./cloudflare/d1/api"

# Cloudflare API for D1 databases.
module Cloudflare::D1
  VERSION = "0.1.0"
  Log     = ::Log.for("d1")
end

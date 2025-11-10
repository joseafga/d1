require "http/client"
require "mime/media_type"
require "./types"
require "./response"

module Cloudflare::D1
  module Api
    extend self

    # Returns a list of D1 databases.
    #
    # A database *name* to search for.
    #
    # *page* number of paginated results.
    # (minimum: 1, default: 1)
    #
    # Number of items *per_page*.
    # (maximum: 10000, minimum: 10, default: 1000)
    def list(name : String? = nil, page : Int32? = nil, per_page : Int32? = nil)
      query = URI::Params.build do |q|
        q.add "name", name unless name.nil?
        q.add "page", page.to_s unless page.nil?
        q.add "per_page", per_page.to_s unless per_page.nil?
      end

      url = URI.parse(D1.config.endpoint)
      url.query = query unless query.empty?

      Response(Array(Database)).from_json request(url: url)
    end

    # Returns the specified D1 database.
    def get(uuid : String)
      url = URI.parse("#{D1.config.endpoint}/#{uuid}")

      Response(Database).from_json request(url: url)
    end

    # Returns the specified D1 database.
    def create(name : String, region : Location?)
      Response(Database).from_json request(method: "POST", body: { name: name, primary_location_hint: region }.to_json)
    end

    # Updates the specified D1 database.
    def update(uuid : String, read_replication : ReadReplication)
      url = URI.parse("#{D1.config.endpoint}/#{uuid}")

      Response(Database).from_json request(method: "PUT", url: url, body: { read_replication: read_replication }.to_json)
    end

    # Updates partially the specified D1 database.
    def update_partial(uuid : String, read_replication : ReadReplication? = nil)
      url = URI.parse("#{D1.config.endpoint}/#{uuid}")
      body = {} of String => ReadReplication
      body["read_replication"] = read_replication unless read_replication.nil?

      Response(Database).from_json request(method: "PATCH", url: url, body: body.to_json)
    end

    # Deletes the specified D1 database.
    def delete(uuid : String)
      url = URI.parse("#{D1.config.endpoint}/#{uuid}")

      Response(Nil).from_json request(method: "DELETE", url: url)
    end

    # Returns the query result as an object.
    #
    # Your *sql* query.
    # Supports multiple statements, joined by semicolons, which will be executed as a batch.
    #
    # SQL *args*.
    # Documentation say `Array<string>` but work with other basic types
    def query(uuid : String, sql : String, args : Array(Any)? = nil)
      url = URI.parse("#{D1.config.endpoint}/#{uuid}/query")

      Response(JSON::Any).from_json request(method: "POST", url: url, body: { sql: sql, params: args }.to_json)
    end

    private def request(**params)
      args = { # default params
        method: "GET",
        url: D1.config.endpoint,
        headers: HTTP::Headers{
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{D1.config.api_token}"
        }
      }.merge(params)
      Log.debug { "Requesting -> #{args}" }

      response = HTTP::Client.exec(**args)
      content_type = MIME::MediaType.parse(response.headers["Content-Type"])

      case content_type.media_type
      when "application/json"
        Log.debug { "Received <- #{response.body}" }

        response.body
      else
        raise "Unknown Content-Type: #{content_type.media_type}"
      end
    end

    # Open a context of the specified D1 database to run multiples queries.
    def self.open(uuid : String, & : Context -> _)
      db = Context.new(uuid)
      yield db
    end

    struct Context
      getter client : DB
      getter uuid : String

      def initialize(@uuid)
        @client = DB.new
      end

      # DB.query wrapper
      def exec(sql : String, args : Array(Any)? = nil)
        client.query(uuid, sql, args)
      end
    end
  end
end

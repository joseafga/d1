require "http/client"
require "mime/media_type"

module D1
  # This module provides most basic interface to the D1 API.
  # Is preferred to use `D1::Database` when possible.
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
    def list(name : String? = nil, page : Int32? = nil, per_page : Int32? = nil) : Array(Database)
      query = URI::Params.build do |q|
        q.add "name", name unless name.nil?
        q.add "page", page.to_s unless page.nil?
        q.add "per_page", per_page.to_s unless per_page.nil?
      end

      url = URI.parse(D1.config.endpoint)
      url.query = query unless query.empty?

      response = request(url: url)
      Response(Array(Database)).from_json(response).to_result
    end

    # Returns the specified D1 database.
    def get(uuid : String) : Database
      url = URI.parse("#{D1.config.endpoint}/#{uuid}")

      response = request(url: url)
      Response(Database).from_json(response).to_result
    end

    # Returns the specified D1 database.
    def create(name : String, region : Location?) : Database
      response = request(method: "POST", body: { name: name, primary_location_hint: region }.to_json)
      Response(Database).from_json(response).to_result
    end

    # Updates the specified D1 database.
    def update(uuid : String, read_replication : ReadReplication) : Database
      url = URI.parse("#{D1.config.endpoint}/#{uuid}")

      response = request(method: "PUT", url: url, body: { read_replication: read_replication }.to_json)
      Response(Database).from_json(response).to_result
    end

    # Updates partially the specified D1 database.
    def update_partial(uuid : String, read_replication : ReadReplication? = nil) : Database
      url = URI.parse("#{D1.config.endpoint}/#{uuid}")
      body = {} of String => ReadReplication
      body["read_replication"] = read_replication unless read_replication.nil?

      response = request(method: "PATCH", url: url, body: body.to_json)
      Response(Database).from_json(response).to_result
    end

    # Deletes the specified D1 database.
    def delete(uuid : String) : Nil
      url = URI.parse("#{D1.config.endpoint}/#{uuid}")

      response = request(method: "DELETE", url: url)
      Response(Nil).from_json(response).to_result
    end

    # Returns the query result as an object.
    #
    # Your *sql* query.
    # Supports multiple statements, joined by semicolons, which will be executed as a batch.
    #
    # SQL *args*.
    # Documentation say `Array<string>` but work with other basic types
    def query(uuid : String, sql : String, args : Array(Any)? = nil) : Array(JSON::Any)
      url = URI.parse("#{D1.config.endpoint}/#{uuid}/query")

      response = request(method: "POST", url: url, body: { sql: sql, params: args }.to_json)
      result = Response(JSON::Any).from_json(response).to_result

      return result[0]["results"].as_a if result[0]["success"].as_bool

      raise "The result failed."
    end

    # Returns the query result rows as arrays rather than objects. This is a performance
    # optimized version of the /query endpoint.
    def raw(uuid : String, sql : String, args : Array(Any)? = nil) : Hash(String, JSON::Any)
      url = URI.parse("#{D1.config.endpoint}/#{uuid}/raw")

      response = request(method: "POST", url: url, body: { sql: sql, params: args }.to_json)
      result = Response(JSON::Any).from_json(response).to_result

      return result[0]["results"].as_h if result[0]["success"].as_bool

      raise "The result failed."
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
  end

  extend Api
end

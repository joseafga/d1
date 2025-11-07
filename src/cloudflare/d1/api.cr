require "http/client"
require "mime/media_type"
require "./types"
require "./response"

module Cloudflare::D1
  ENDPOINT = "https://api.cloudflare.com/client/v4"

  # d1.database
  #
  # curl https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/d1/database \
  #     -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
  #     -H "X-Auth-Key: $CLOUDFLARE_API_KEY"\
  #
  # List D1 Databases -> V4PagePaginationArray<{ created_at, name, uuid, 1 more... }>
  # get/accounts/{account_id}/d1/database

  # Returns a list of D1 databases.
  # Security

  # The preferred authorization scheme for interacting with the Cloudflare API. Create a token.

  # Example: Authorization: Bearer Sn3lZJTBX6kkg7OdcBUAxOO963GEIyGQqnFTOFYY
  # Accepted Permissions (at least one required)

  # D1 Read D1 Write
  # path Parameters
  # account_id: string
  # (maxLength: 32)

  # Account identifier tag.
  # query Parameters
  # name: stringOptional

  # a database name to search for.
  # page: numberOptional
  # (minimum: 1, default: 1)

  # Page number of paginated results.
  # per_page: numberOptional
  # (maximum: 10000, minimum: 10, default: 1000)

  # Number of items per page.
  class DB
    @endpoint : String
    @headers : HTTP::Headers

    # Configuration parameters are optional and non-initialized, so they must be defined later
    def initialize
      @endpoint = "#{ENDPOINT}/accounts/#{Cloudflare::D1.config.account_id}/d1/database"
      @headers = HTTP::Headers{
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{Cloudflare::D1.config.api_token}"
      }
    end

    # Returns a list of D1 databases.
    #
    # *query* parameters:
    #
    # A database name to search for. *(Optional)*
    # *name*: String
    #
    # Page number of paginated results. *(Optional)*
    # *page*: Number
    # (minimum: 1, default: 1)
    #
    # Number of items per page. *(Optional)*
    # *per_page*: Number
    # (maximum: 10000, minimum: 10, default: 1000)
    def list(name : String? = nil, page : Int32? = nil, per_page : Int32? = nil)
      query = URI::Params.build do |q|
        q.add "name", name unless name.nil?
        q.add "page", page.to_s unless page.nil?
        q.add "per_page", per_page.to_s unless per_page.nil?
      end

      url = URI.parse(@endpoint)
      url.query = query unless query.empty?

      Response(Array(Database)).from_json request(url: url)
    end

    # Returns the specified D1 database.
    def get(uuid : String)
      url = URI.parse("#{@endpoint}/#{uuid}")

      Response(Database).from_json request(url: url)
    end

    # Returns the specified D1 database.
    def create(name : String, region : Location?)
      Response(Database).from_json request(method: "POST", body: { name: name, primary_location_hint: region }.to_json)
    end

    # Updates the specified D1 database.
    def update(uuid : String, read_replication : ReadReplication)
      url = URI.parse("#{@endpoint}/#{uuid}")

      Response(Database).from_json request(method: "PUT", url: url, body: { read_replication: read_replication }.to_json)
    end

    # Updates partially the specified D1 database.
    def update_partial(uuid : String, read_replication : ReadReplication? = nil)
      url = URI.parse("#{@endpoint}/#{uuid}")
      body = {} of String => ReadReplication
      body["read_replication"] = read_replication unless read_replication.nil?

      Response(Database).from_json request(method: "PATCH", url: url, body: body.to_json)
    end

    # Deletes the specified D1 database.
    def delete(uuid : String)
      url = URI.parse("#{@endpoint}/#{uuid}")

      Response(Nil).from_json request(method: "DELETE", url: url)
    end

    # Returns the query result as an object.
    #
    # *sql* Your SQL query.
    # Supports multiple statements, joined by semicolons, which will be executed as a batch.
    #
    # *args* SQL arguments. *(Optional)*
    # Documentation say `Array<string>` but work with other basic types
    def query(uuid : String, sql : String, args : Array(Any)? = nil)
      url = URI.parse("#{@endpoint}/#{uuid}/query")

      Response(JSON::Any).from_json request(method: "POST", url: url, body: { sql: sql, params: args }.to_json)
    end

    private def request(**params)
      Log.debug { "Requesting -> #{params}" }
      args = {method: "GET", url: @endpoint, headers: @headers}.merge(params)

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

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
      @headers = HTTP::Headers{"Authorization" => "Bearer #{Cloudflare::D1.config.api_token}"}
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
    def list(query = nil)
      @headers["Content-Type"] = "application/json"
      response = request(query: query)

      Response(Array(Database)).from_json response
    rescue ex : JSON::SerializableError
      raise Cloudflare::D1::BadResponseException.new "Can't parse JSON response"
    end

    # Returns the specified D1 database.
    def get(uuid : String)
      @headers["Content-Type"] = "application/json"
      response = request(path: "/#{uuid}")

      Response(Database).from_json response
    rescue ex : JSON::SerializableError
      raise Cloudflare::D1::BadResponseException.new "Can't parse JSON response"
    end

    # Returns the specified D1 database.
    def create(name : String, region : HintLocation?)
      @headers["Content-Type"] = "application/json"
      response = request("POST", body: { name: name, primary_location_hint: region }.to_json)

      Response(Database).from_json response
    rescue ex : JSON::SerializableError
      raise Cloudflare::D1::BadResponseException.new "Can't parse JSON response"
    end

    private def request(method = "GET", path : String? = nil, query = nil, body = nil)
      Log.debug { "Requesting -> #{method}, path: #{path}, query: #{query}" }

      url = URI.parse("#{@endpoint}#{path}")
      url.query = URI::Params.encode(query) unless query.nil?

      response = HTTP::Client.exec method, url, headers: @headers, body: body
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
end

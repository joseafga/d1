module D1
  # The details of the D1 database.
  struct Database
    include JSON::Serializable

    # Specifies the timestamp the resource was created as an ISO8601 string. *(Optional)*
    getter! created_at : Time
    # The D1 database's size, in bytes. *(Optional)*
    getter! file_size : Int32
    # D1 database name. *(Optional)*
    getter! name : String
    # *(Optional)*
    getter! num_tables : Int32
    # *(Optional)*
    getter! running_in_region : Location
    # Configuration for D1 read replication. *(Optional)*
    getter! read_replication : ReadReplication
    # D1 database identifier (UUID). *(Optional)*
    getter! uuid : String
    # *(Optional)*
    getter! version : String
    # Check if
    getter? fetched = false

    def initialize(@uuid)
    end
  end

  # The read replication mode for the database. Use 'auto' to create replicas and allow
  # D1 automatically place them around the world, or 'disabled' to not use any database
  # replicas (it can take a few hours for all replicas to be deleted).
  record ReadReplication, mode : Mode do
    include JSON::Serializable

    enum Mode
      AUTO
      DISABLED
    end
  end

  # The following hint locations are supported
  enum Location
    WNAM
    ENAM
    WEUR
    EEUR
    APAC
    OC
  end

  alias Any = String | Int32 | Int64 | Float64 | Bool
end

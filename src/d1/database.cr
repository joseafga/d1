module D1
  def self.open(uuid, & : Database -> _)
    db = Database.new(uuid)

    yield db
  end

  def self.get(uuid, & : Database -> _)
    db = Api.get(uuid)

    yield db
  end

  # This is the primary way to interact with the D1 database.
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

    def initialize(@uuid)
    end

    # The same as `D1::Api#update_database` with #uuid already
    def update(read_replication : ReadReplication)
      D1.update_database(uuid, read_replication)
    end

    # The same as `D1::Api#update_partial` with #uuid already
    def update_partial(read_replication : ReadReplication? = nil)
      D1.update_database(uuid, read_replication)
    end

    # The same as `D1::Api#delete` with #uuid already
    def delete
      D1.delete(uuid)
    end

    # Wrapper to `D1::Api#raw` but returns `Nil`
    def exec(query, *values, args = [] of Any) : Nil
      values.each do |value|
        args.push value
      end

      Api.raw(uuid, query, args)
    end

    # Wrapper to `D1::Api#query`
    def query(query, *values, args = [] of Any)
      values.each do |value|
        args.push value
      end

      Api.query(uuid, query, args)
    end

    # Wrapper to `D1::Api#raw`
    def raw(query, *values, args = [] of Any)
      values.each do |value|
        args.push value
      end

      Api.raw(uuid, query, args)
    end
  end
end

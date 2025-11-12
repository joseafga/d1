module D1
  def self.open(uuid, & : Context -> _)
    ctx = Context.new(uuid)

    yield ctx
  end

  class Context
    @uuid : String?
    @db : Database?

    def initialize(uuid : String)
      @uuid = uuid
      @db = nil
    end

    def initialize(db : Database)
      @uuid = nil
      @db = db
    end

    def exec(query, *values, args = [] of Any) : Nil
      values.each do |value|
        args.push value
      end

      Api.query(uuid, query, args)
      Nil
    end

    def query(query, *values, args = [] of Any)
      values.each do |value|
        args.push value
      end

      Api.query(uuid, query, args)
    end

    def db : Database
      if @db.nil?
        @db = Api.get(@uuid)
      end

      @db
    end

    # The database is loaded lazily but sometimes you won't need the database information.
    # If the UUID is available and you only need it, use this method instead of `@db.uuid`.
    private def uuid : String
      if db = @db
        return db.uuid
      end

      @uuid.not_nil!
    end
  end
end

module D1
  def self.open(uuid, & : Context -> _)
    ctx = Context.new(uuid)

    yield ctx
  end

  class Context
    @db : Database

    def initialize(uuid : String)
      @db = Database.new(uuid)
    end

    def initialize(db : Database)
      @db = db
    end

    def exec(query, *values, args = [] of Any) : Nil
      values.each do |value|
        args.push value
      end

      Api.query(@db.uuid, query, args)
      Nil
    end

    def query(query, *values, args = [] of Any)
      values.each do |value|
        args.push value
      end

      Api.query(@db.uuid, query, args)
    end
  end
end

require "./spec_helper"

describe Cloudflare::D1 do

  it "List D1 Databases" do
    db = Cloudflare::D1::DB.new
    # basic list
    db.list
    # list with query params
    db.list "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", page: 1, per_page: 10
  end

  it "Get D1 Database" do
    db = Cloudflare::D1::DB.new
    db.get "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  end

  it "Create D1 Database" do
    db = Cloudflare::D1::DB.new
    db.create "mydb", :enam
  end

  it "Update D1 Database" do
    db = Cloudflare::D1::DB.new
    db.update "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", Cloudflare::D1::ReadReplication.new(:auto)
  end

  it "Update D1 Database Partially" do
    db = Cloudflare::D1::DB.new
    db.update_partial "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  end

  it "Delete D1 Database" do
    db = Cloudflare::D1::DB.new
    db.delete "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  end

  it "Query D1 Database" do
    db = Cloudflare::D1::DB.new
    db.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "CREATE TABLE Users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, age INTEGER)"
    db.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "INSERT INTO Users (name, age) VALUES ('John', 25)"
    result = db.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "SELECT * FROM Users WHERE name = ?", args: ["John"]
    # db.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "SELECT * FROM Users WHERE age = ?", args: [25]
    result.result[0]["results"][0]["age"].as_i.should eq 25
  end

  it "Execute multiples queries on D1 Database" do
    age = 0

    Cloudflare::D1::DB.open("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx") do |db|
      db.exec "INSERT INTO Users (name, age) VALUES ('Billy', 30)"
      result = db.exec "SELECT * FROM Users WHERE name = ?", args: ["Billy"]

      age = result.result[0]["results"][0]["age"].as_i
    end

    age.should eq 30
  end

  # it "Raw D1 Database Query" do
  # end
end

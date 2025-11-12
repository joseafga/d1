require "./spec_helper"

describe D1 do

  it "List D1 Databases" do
    list = D1::Api.list
    list.should be_a(Array(D1::Database))
  end

  it "List D1 Databases with query params" do
    list = D1::Api.list "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", page: 1, per_page: 10
    list.should be_a(Array(D1::Database))
  end

  it "Get D1 Database" do
    D1::Api.get "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  end

  it "Create D1 Database" do
    D1::Api.create "mydb", :enam
  end

  it "Update D1 Database" do
    D1::Api.update "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", D1::ReadReplication.new(:auto)
  end

  it "Update D1 Database Partially" do
    D1::Api.update_partial "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  end

  it "Delete D1 Database" do
    D1::Api.delete "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  end

  it "Query D1 Database" do
    D1::Api.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "CREATE TABLE Users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, age INTEGER);"
    D1::Api.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "INSERT INTO Users (name, age) VALUES ('John', 25)"
    result = D1::Api.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "SELECT * FROM Users WHERE name = ?", args: ["John"]
    # D1::Api.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "SELECT * FROM Users WHERE age = ?", args: [25]
    # result.result[0]["results"][0]["age"].as_i.should eq 25
  end

  # it "Raw D1 Database Query" do
  # end

  it "Query D1 Database like crystal-db" do
    name = ""

    D1.open("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx") do |db|
      db.exec "CREATE TABLE Users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, age INTEGER);"
      db.exec "INSERT INTO Users (name, age) VALUES ('Billy', 30)"
      result = db.query "SELECT * FROM Users WHERE age = ?", 30
      name = result.first["name"].as_s
    end

    name.should eq "Billy"
  end
end

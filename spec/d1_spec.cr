require "./spec_helper"

describe D1 do

  it "List D1 Databases" do
    list = D1.list
    list.should be_a(Array(D1::Database))
  end

  it "List D1 Databases with query params" do
    list = D1.list "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", page: 1, per_page: 10
    list.should be_a(Array(D1::Database))
  end

  it "Get D1 Database" do
    db = D1.get "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    db.uuid.should eq "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  end

  it "Create D1 Database" do
    db = D1.create "mydb", :enam
    db.name.should eq "mydb"
  end

  it "Update D1 Database" do
    db = D1.update "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", D1::ReadReplication.new(:auto)
    db.read_replication.mode.should eq D1::ReadReplication::Mode::AUTO
  end

  it "Update D1 Database Partially" do
    D1.update_partial "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  end

  it "Delete D1 Database" do
    D1.delete "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  end

  it "Query D1 Database" do
    D1.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "CREATE TABLE Users (id INTEGER PRIMARY KEY, name TEXT NOT NULL, age INTEGER);"
    D1.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "INSERT INTO Users (name, age) VALUES ('John', 25)"
    result = D1.query "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "SELECT * FROM Users WHERE age = ?", args: [25]
    result.first["age"].as_i.should eq 25
  end

  it "Raw D1 Database Query" do
    D1.raw "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "INSERT INTO Users (name, age) VALUES ('Billy', 30)"
    result = D1.raw "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", "SELECT * FROM Users WHERE name = ?", args: ["Billy"]
    result["columns"].as_a.should eq ["id", "name", "age"]
    result["rows"][0][1].as_s.should eq "Billy"
  end

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

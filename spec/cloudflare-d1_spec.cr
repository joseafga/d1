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

  # it "Update D1 Database" do
  #   db = Cloudflare::D1::DB.new
  #   db.update "database_id"
  # end

  # it "Update D1 Database Partially" do
  #   db = Cloudflare::D1::DB.new
  #   db.update_partial "database_id"
  # end

  # it "Delete D1 Database" do
  #   db = Cloudflare::D1::DB.new
  #   db.delete "database_id"
  # end

  # it "Query D1 Database" do
  #   db = Cloudflare::D1::DB.new
  #   db.exec "SELECT * FROM Customers WHERE CompanyName = ?", args: "Bs Beverages"
  # end

  # it "Raw D1 Database Query" do
  # end
end

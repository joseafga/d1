require "./spec_helper"

describe D1 do

  it "List D1 Databases" do
    D1::Response(Array(D1::Database)).from_json Samples.load_json("response_list")
  end

  it "Get D1 Database" do
    D1::Response(D1::Database).from_json Samples.load_json("response_get")
  end

  it "Get D1 Database with error" do
    D1::Response(D1::Database).from_json Samples.load_json("response_get_error")
  end

  it "Query D1 Database with error on params" do
    D1::Response(JSON::Any).from_json Samples.load_json("response_query_error")
  end
end

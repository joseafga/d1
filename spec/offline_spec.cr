require "./spec_helper"

describe Cloudflare::D1 do

  it "List D1 Databases" do
    Cloudflare::D1::Response(Array(Cloudflare::D1::Database)).from_json Samples.load_json("response_list")
  end

  it "Get D1 Database" do
    Cloudflare::D1::Response(Cloudflare::D1::Database).from_json Samples.load_json("response_get")
  end

  it "Get D1 Database with error" do
    Cloudflare::D1::Response(Cloudflare::D1::Database).from_json Samples.load_json("response_get_error")
  end
end

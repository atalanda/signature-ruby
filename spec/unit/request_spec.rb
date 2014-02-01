require 'spec_helper'
describe Atalanda::Signature::Request do
  before(:each) do
    @api_key = "dqwffef2"
    @token = Atalanda::Signature::Token.new(@api_key,"g234h24g34")
  end

  after(:each) do
    Timecop.return
  end

  describe "canonical_string_from_hash" do
    it "should always output the same string" do
      params = {
        "atalogics" => {
          "api_key" => "5f70fd232454e5c142566dbacc3dec5",
          "external_id" => "AZDF-234",
          "catch" => {
              "name" => "Top Fashion Shop",
              "street" => "Schneiderstrasse 20"
          },
          "drop" => {
              "name" => "Marta Musterkundin",
              "street" => "Kaufstr. 76"
          },
          "an_array" => [2,"3","1","5"]
        }
      }
      request = Atalanda::Signature::Request.new("POST", "/api/order", params)
      result = request.send(:buildParameterString)

      params2 = {
        "atalogics" => {
          "external_id" => "AZDF-234",
          "api_key" => "5f70fd232454e5c142566dbacc3dec5",
          "drop" => {
              "name" => "Marta Musterkundin",
              "street" => "Kaufstr. 76"
          },
          "an_array" => [2,"3","1","5"],
          "catch" => {
              "street" => "Schneiderstrasse 20",
              "name" => "Top Fashion Shop"
          }
        }
      }
      request2 = Atalanda::Signature::Request.new("POST", "/api/order", params2)
      result2 = request2.send(:buildParameterString)

      result2.should == result
    end

    it "should concatenate correctly" do
      params = {
        "atalogics" => {
          "api_key" => "5f70fd232454e5c142566dbacc3dec5",
          "external_id" => "AZDF-234",
          "catch" => {
              "name" => "Top Fashion Shop",
              "street" => "Schneiderstrasse 20"
          },
          "drop" => {
              "name" => "Marta Musterkundin",
              "street" => "Kaufstr. 76"
          },
          "an_array" => [2,"3","1","5"],
          "zip" => false
        }
      }
      request = Atalanda::Signature::Request.new("POST", "/api/order", params)
      result = request.send(:buildParameterString)
      result.should == "POST/api/orderatalogicsan_array2315api_key5f70fd232454e5c142566dbacc3dec5catchnameTop Fashion ShopstreetSchneiderstrasse 20dropnameMarta MusterkundinstreetKaufstr. 76external_idAZDF-234zipfalse"
    end
  end

  describe "sign" do
    it "should correctly sign a request" do
      Timecop.freeze(Date.parse("20.12.2014")) do
        params = {"foo" => "bar"}
        request = Atalanda::Signature::Request.new("POST", "/api/order", params)
        signedParams = request.sign(@token)
        signedParams.should == {
          "foo" => "bar",
          "auth_timestamp"=>1419030000, 
          "auth_key"=>@api_key, 
          "auth_signature"=>"e89983606e992b9b060e9383913de79ebc6a1d610c96bf4f9712e6813d4fedfa"
        }
      end
    end
  end

  describe "authenticate" do
    it "should not authenticate if there is no auth_hash" do
      Timecop.freeze(Date.parse("20.12.2014")) do
        params = {"foo" => "bar"}
        request = Atalanda::Signature::Request.new("POST", "/api/order", params)
        result = request.authenticate(@token)
        result.should == {
          "authenticated" => false,
          "reason" => "Auth hash is missing"
        }
      end
    end

    it "should not authenticate if signature is too old" do
      Timecop.travel(Date.parse("20.12.2014"))
      params = {"foo" => "bar"}
      request = Atalanda::Signature::Request.new("POST", "/api/order", params)
      signedParams = request.sign(@token)

      Timecop.travel(Date.parse("21.12.2014"))
      request2 = Atalanda::Signature::Request.new("POST", "/api/order", signedParams)
      timestamp_grace = 700
      result = request2.authenticate(@token, timestamp_grace)
      result.should == {
        "authenticated" => false,
        "reason" => "Auth timestamp is older than #{timestamp_grace} seconds"
      }
    end

    it "should not authenticate if content changed" do
      params = {"foo" => "bar"}
      request = Atalanda::Signature::Request.new("POST", "/api/order", params)
      signedParams = request.sign(@token)

      # change params
      signedParams["foo"] = "bar2"

      request2 = Atalanda::Signature::Request.new("POST", "/api/order", signedParams)
      timestamp_grace = 700
      result = request2.authenticate(@token, timestamp_grace)
      result.should == {
        "authenticated" => false,
        "reason" => "Signature does not match"
      }
    end

    it "should not authenticate" do
      params = {"foo" => "bar"}
      request = Atalanda::Signature::Request.new("POST", "/api/order", params)
      signedParams = request.sign(@token)

      request2 = Atalanda::Signature::Request.new("POST", "/api/order", signedParams)
      timestamp_grace = 700
      result = request2.authenticate(@token, timestamp_grace)
      result.should == {
        "authenticated" => true
      }
    end
  end
end
AtalandaSignature-ruby
==================

AtalandaSignature-ruby provides a simple Ruby class that lets you sign requests to the [atalogics API](http://atalogics.com) and verify our callbacks.

Installation
============

The best way to install the library is by using bundler. Add the following to `Gemfile` in the root of your project:

``` 
gem "atalanda-signature"
```

Then, on the command line:

``` bash
bundle install
```

Usage
=====

Signing API calls
-----------------
Use this to add an auth_hash containing a valid signature to the parameter hash that you send to our API.
``` ruby
parameters = {
  "atalogics" => {}
}
token = Atalanda::Signature::Token.new(KEY, SECRET)
request = Atalanda::Signature::Request.new("POST", "https://atalogics.com/api/order", parameters)
signed_parameters = request.sign(token)
=>
{
  "atalogics" => {},
  "auth_timestamp" => 1391167211,
  "auth_key" => "[Your API key]",
  "auth_signature" => "552beac4b99949a556b120b7e5f7e22def46f663992a08f0f132ad4afee68b9f"
}
```
**Example**
> POST Request to https://atalogics.com/api/orderOffer with the following JSON:
``` javascript
{
  "atalogics": {
    "api_key": "5f70fd232454e5c142566dbacc3dec5",
    "offer_id": "33/2014-01-22/1/2014-01-22",
    "expected_fee": 5.59,
    "external_id": "AZDF-234",
    "url_state_update": "https://ihr-server.de/atalogics/callbacks",
    "catch": {
        "name": "Top Fashion Shop",
        "street": "Schneiderstraße 20",
        "postal_code": "5020",
        "city": "Salzburg",
        "phone_number": "123456",
        "email": "info@fashionshop.de"
    },
    "drop": {
        "name": "Marta Musterkundin",
        "street": "Kaufstr. 76",
        "postal_code": "5020",
        "city": "Salzburg",
        "phone_number": "435236",
        "email": "marta@musterkundin.de",
        "extra_services": ["R18"]
    }
  }
}
```
``` ruby
token = Atalanda::Signature::Token.new(KEY, SECRET)
request = Atalanda::Signature::Request.new("POST", "https://atalogics.com/api/orderOffer", parameters) # parameters contains a hash representing the json above
signed_parameters = request.sign(token)
# post to our API, for example with HTTParty
HTTParty.post("https://atalogics.com/api/orderOffer", 
  :body => signed_parameters.to_json,
  :headers => { 'Content-Type' => 'application/json' })
```
If you do a GET Request, you also have to sign all URL parameters. Simply include them in the parameters hash. Send the produced auth parameters along with the other URL parameters, for example:
> https://atalogics.com/api/status?tracking_id=42ef32a&api_key=abcde**&auth_signature=ab332d2f&auth_timestamp=123244&auth_key=abcde**


Verifying the signature of our callbacks
--------------
Use this to verify the signature of our callbacks.
``` ruby
data = JSON.parse(body) // convert json from post body into ruby hash
token = Atalanda::Signature::Token.new(KEY, SECRET)
request = Atalanda::Signature::Request.new("POST", "api/order", data)
result = request.authenticate(token)

if result["authenticated"] == true
  // signature is valid
end
```



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
request = Atalanda::Signature::Request.new("POST", "api/order", parameters)
signed_parameters = request.sign(token)
=>
{
  "atalogics" => {},
  "auth_timestamp" => 1391167211,
  "auth_key" => "[Your API key]",
  "auth_signature" => "552beac4b99949a556b120b7e5f7e22def46f663992a08f0f132ad4afee68b9f"
}
```

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


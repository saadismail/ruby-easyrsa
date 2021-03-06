# ruby-easyrsa
[![Build Status](https://travis-ci.org/mikemackintosh/ruby-easyrsa.svg)](https://travis-ci.org/mikemackintosh/ruby-easyrsa)

[![](http://ruby-gem-downloads-badge.herokuapp.com/easyrsa?type=total)](https://rubygems.org/gems/easyrsa)

[![Dependency Status](https://gemnasium.com/mikemackintosh/ruby-easyrsa.svg)](https://gemnasium.com/mikemackintosh/ruby-easyrsa)

[![Gem Version](https://badge.fury.io/rb/easyrsa.svg)](https://rubygems.org/gems/easyrsa)


Generate OpenVPN certificate and keys with Ruby using this gem.

## Installation

Via command line use `gem`:

```shell
gem install easyrsa
```

or add it to your projects `Gemfile`:
```ruby
gem 'easyrsa'
```

and simply require it in your code:

```ruby
require 'easyrsa'
```

## Usage

First, set your issuer configuration like so:

```ruby
EasyRSA.configure do |issuer|
  issuer.email = 'support@company.com'
  issuer.name = 'MrKickass'
  issuer.server = 'vpnserver.company.com'
  issuer.country = 'US'
  issuer.state = 'NY'
  issuer.city = 'New York'
  issuer.company = 'My Company'
  issuer.orgunit = 'IT'
end
```

### Generate a Client Certificate

Use the `EasyRSA::Certificate` class to generate the certificate:

```ruby
cn = 'Users Common Name'
email = 'users-common-name@company.com'
easyrsa = EasyRSA::Certificate.new(@ca_cert, @ca_key, cn, email)
g = easyrsa.generate
 #=> [:key => '...RSA KEY...', :crt => '...CERTIFICATE...']
```

>**Note** `ca_cert` and `ca_key` should point to the same certificate and keys that are included in your OpenVPN configuration file.

### Generate the CA files

The following can be used to create a Certificate Authority:

```ruby
ca = EasyRSA::CA.new('CN=openvpn/DC=example/DC=com')
g = ca.generate
 #=> [:key => '...RSA KEY...', :crt => '...CERTIFICATE...']
```


### Revoking Certificates

The following can be used to create revoke a certificate:

```ruby
easyrsa = EasyRSA::Certificate.new(@ca_cert, @ca_key, 'mike', 'mike@ruby-easyrsa.gem')
g = easyrsa.generate

r = EasyRSA::Revoke.new g[:crt]
crl = r.revoke! @ca_key
 #=> -----BEGIN X509 CRL-----
 #   MIIBjTCB9wIBATANBgkqhkiG9w0BAQsFADCBpDELMAkGA1UEBhMCVVMxETAPBgNV
```

### Generating Deffie-Hellman

The following can be used to generate Deffie-Hellman:

```ruby
easyrsa = EasyRSA::DH.new
g = easyrsa.generate
puts g
 #=> -----BEGIN DH PARAMETERS-----
```

## Credits

Many thanks to:

  - [@chapmajs](https://github.com/chapmajs)
  - [@esaari](https://github.com/esaari)

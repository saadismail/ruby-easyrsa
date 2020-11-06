module EasyRSA
  class CA

    class BitLengthToWeak < RuntimeError; end
    class InvalidCAName < RuntimeError; end
    class MissingParameter < RuntimeError; end

    def initialize(ca_name=nil, bits=4096, &block)

    # CA Name to generate cert for
      begin
        if ca_name.eql? nil
          raise EasyRSA::CA::MissingParameter,
            "Please provide a 'ca name', for the certificates' CN field. This should be in the format, 'CN=ca/DC=example/DC=com' for 'ca.example.com'"
        end
        @ca_name = OpenSSL::X509::Name.parse ca_name
      rescue TypeError => e
        fail EasyRSA::CA::InvalidCAName, 
          "Please provide a 'ca name', for the certificates' CN field. This should be in the format, 'CN=ca/DC=example/DC=com' for 'ca.example.com'"
      end
    
    # Generate Private Key
      if bits < 2048
        raise EasyRSA::CA::BitLengthToWeak,
          "Please select a bit length greater than 2048. Default is 4096. You chose '#{bits}'"
      end      
      @ca_key = OpenSSL::PKey::RSA.new(bits)

    # Instantiate a new certificate
      @ca_cert = OpenSSL::X509::Certificate.new

    # This cert should never be valid before now
      @ca_cert.not_before = Time.now

    # Set it to version
      @ca_cert.version = 2     
    
    # Generate and assign the serial
      @ca_cert.serial = 0

      instance_eval(&block) if block_given?
    end

    def generate(validfor=10)
  
    # Set the expiration date
      @ca_cert.not_after = EasyRSA::years_from_now(validfor)

    # Add the public key
      @ca_cert.public_key = @ca_key.public_key

    # Set the CA Cert Subject
      @ca_cert.subject = @ca_name

    # Set the CA Cert Subject
      gen_issuer

    # Add extensions
      add_extensions

    # Sign the cert
      sign_cert

      { key: @ca_key.to_pem, crt: @ca_cert.to_pem }

    end

    private

    # Cert issuer details
      def gen_issuer
        # name = "/C=#{EasyRSA::Config.country}"
        # name += "/ST=#{EasyRSA::Config.state}" unless !EasyRSA::Config.state || EasyRSA::Config.state.empty?
        # name += "/L=#{EasyRSA::Config.city}"
        # name += "/O=#{EasyRSA::Config.company}"
        # name += "/OU=#{EasyRSA::Config.orgunit}"
        # name += "/CN=#{EasyRSA::Config.server}"
        # name += "/name=#{EasyRSA::Config.name}" unless !EasyRSA::Config.name || EasyRSA::Config.name.empty?
        # name += "/name=#{EasyRSA::Config.orgunit}" if !EasyRSA::Config.name || EasyRSA::Config.name.empty?
        # name += "/emailAddress=#{EasyRSA::Config.email}"

        name = "/CN=#{EasyRSA::Config.server}"

        @ca_cert.issuer = OpenSSL::X509::Name.parse(name)
      end

    # Add Extensions needed
      def add_extensions
        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = @ca_cert
        ef.issuer_certificate = @ca_cert

        @ca_cert.extensions = [
          ef.create_extension("subjectKeyIdentifier", "hash"),
          ef.create_extension("basicConstraints","CA:TRUE", true),
          ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
        ]
        @ca_cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                               "keyid:always,issuer:always")

        # @ca_cert.add_extension ef.create_extension('subjectKeyIdentifier', 'hash')
        # @ca_cert.add_extension ef.create_extension('basicConstraints', 'CA:TRUE', true)
        # @ca_cert.add_extension ef.create_extension('keyUsage', 'cRLSign,keyCertSign', true)

      end

    # Sign cert with CA key
      def sign_cert
        @ca_cert.sign @ca_key, OpenSSL::Digest::SHA256.new
      end

  end
end

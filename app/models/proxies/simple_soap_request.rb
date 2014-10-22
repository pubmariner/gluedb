module Proxies
  class SimpleSoapRequest
    def self.request(en_id)
      self.new.request(en_id)
    end

    def request(en_id)
      uri = URI.parse(endpoint)
      req = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'text/xml'})
      req.body = template(en_id)
      Net::HTTP.new(uri.host, uri.port).request(req).body
    end

    def osb_host
      ExchangeInformation.osb_host
    end

    def endpoint
      osb_host + service_location
    end
  end
end

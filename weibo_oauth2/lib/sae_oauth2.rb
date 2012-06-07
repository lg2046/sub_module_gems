require "base64"

class OpenSina
  include HTTMultiParty
  base_uri "https://api.weibo.com"
  headers "User-Agent" => "Sae OAuth2 v0.1"
end

class SaeOauth2
  attr_accessor :client_id, :client_secret, :access_token, :refresh_token
  attr_reader :access_token_url, :authorize_url

  def initialize(client_id, client_secret, access_token = nil, refresh_token = nil)
    @access_token_url = "https://api.weibo.com/oauth2/access_token"
    @authorize_url = "https://api.weibo.com/oauth2/authorize"

    @client_id = client_id
    @client_secret = client_secret
    @access_token = access_token
    @refresh_token = refresh_token
  end

  ######################################################
  #
  # @param string $signed_request 应用框架在加载iframe时会通过向Canvas URL post的参数signed_request
  #
  #####################################################
  def parse_signed_request(signed_request)
    encoded_sig, payload = signed_request.split(".")
    sig = Base64.decode64_url(encoded_sig)
    begin
      data = JSON.parse(Base64.decode64_url(payload))
    rescue Exception => e
      return nil
    end
    return nil if data["algorithm"].upcase != "HMAC-SHA256"

    expected_sig = OpenSSL::HMAC.digest("sha256", self.client_secret, payload)
    (sig != expected_sig) ? nil : data
  end

  def get(url, parameters = {})
    response = self.oauth_request(url, 'GET', parameters)
    JSON.parse(response)
  end

  def post(url, parameters = {})
    response = self.oauth_request(url, 'POST', parameters)
    JSON.parse(response)
  end

  def oauth_request(url, method, parameters)
    url = "#{@host}#{url}.json" unless url.starts_with?("https://")
    case method
    when 'GET'
      OpenSina.get(url, :query => parameters,  :headers => {"Authorization" => "OAuth2 #{@access_token}"}).body
    when 'POST'
      OpenSina.post(url, :query => parameters, :headers => {"Authorization" => "OAuth2 #{@access_token}"}).body
    end
  end
end

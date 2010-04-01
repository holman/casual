require 'net/https'
require 'nokogiri'

module Casual
  class Client
    attr_accessor :server_path, :callback_url, :port
    
    def initialize(config)
      @server_path = config[:server_path]
      @callback_url = config[:callback_url]
      @port = config[:port] || 443
    end

    def authorization_url
      "#{server_url}/login?service=#{callback_url}"
    end

    def authenticate(username,password)
      ticket = acquire_ticket
      params = "username=#{username}&password=#{password}&lt=#{ticket}"
      status,response = connection.post('/login', params)#.last
      (status.code == '200') ? username : nil
    end
    
    def acquire_ticket
      login_page = connection.get('/login')
      Nokogiri::HTML(login_page.body).css('input#lt').first['value']
    end

    def connection
      http = Net::HTTP.new(server_path, port)
      http.use_ssl = true
      http
    end
    
    def authenticate_ticket(ticket)
      connection.get("/serviceValidate?service=#{callback_url}&ticket=#{ticket}").body
    end
    
    def user_login(ticket)
      user = Nokogiri::XML(authenticate_ticket(ticket)).xpath('//cas:authenticationSuccess //cas:user').text
      user.strip != '' ? user : nil
    end
    
    def server_url
      "https://#{server_path}:#{port}"
    end
    
  end
end
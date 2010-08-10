require 'net/https'
require 'hpricot'

module Casual
  class Client
    attr_accessor :hostname, :path, :https, :port, :callback_url

    def initialize(config)
      @hostname     = config[:hostname]
      @path         = config[:path]
      @https        = config[:https]
      @port         = config[:port] || 443
      @callback_url = config[:callback_url]
    end

    def authorization_url
      "#{server_url}/login?service=#{callback_url}"
    end

    def authenticate(username,password)
      login_page = connection.get("/#{no_slash_path}/login")
      headers = { 'Cookie' => login_page.response["set-cookie"] }
      ticket = acquire_ticket(login_page)
      params = "username=#{username}&password=#{password}&lt=#{ticket}"
      params << '&_eventId=submit&submit=LOGIN'

      status,response =
          connection.post("/#{no_slash_path}/login", params, headers)

      if response =~ /JA-SIG/
        (response =~ /Log In Successful/) ? username : nil
      else
        status.code == '200' ? username : nil
      end
    end

    def acquire_ticket(login_page)
      ticket = Hpricot(login_page.body).search('input[@name=lt]').first
      ticket ? ticket['value'] : nil
    end

    def connection
      http = Net::HTTP.new(hostname, port)
      http.use_ssl = @https
      http
    end

    def authenticate_ticket(ticket)
      connection.
        get("/#{no_slash_path}/serviceValidate?service=#{callback_url}" +
            "&ticket=#{ticket}").
        body
    end

    def user_login(ticket)
      user = Hpricot::XML(authenticate_ticket(ticket)).
                search('//cas:authenticationSuccess //cas:user').text
      user.strip != '' ? user : nil
    end

    def server_url
      "#{protocol}://#{hostname}:#{port}/#{no_slash_path}"
    end

    def protocol
      https ? 'http' : 'https'
    end

    def no_slash_path
      path[0] == 47 ? path[1..path.size] : path
    end

  end
end
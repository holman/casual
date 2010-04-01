# Casual
### Casual is a tiny [CAS](http://en.wikipedia.org/wiki/Central_Authentication_Service) client

There's a [few](http://github.com/gunark/rubycas-client) [CAS](http://github.com/p8/casablanca) [clients](http://github.com/jamesarosen/casrack_the_authenticator) in [the Ruby world](http://github.com/search?langOverride=&language=rb&q=cas&repo=&start_value=1&type=Repositories&x=25&y=13). Go check them out; there's a very good chance they'll fit your needs. I'll wait.

Cool. What I didn't like from existing solutions was that they assumed you were using Rails, they assumed you would use CAS in a particular fashion, and CAS seemed too straightforward to muddy it up with a ten-thousand line client library.

Casual is a übertiny client that doesn't hook into a Rails `before_filter` or deep into Rack middleware. It'll work in irb, it'll work in a simple controller, it'll work underwater. It's based off of another tiny client from [Texas A&M](http://http.tamu.edu/auth/caslibraries/ruby/), except generalized for use outside the school and to avoid REXML (ew).

Casual will work for casual use, like simple and straightforward authentication requirements or as a way to programmatically play around with and understand CAS itself.

## Codes

### Fake end-to-end CAS authentication
This bypasses the intermediary CAS single sign-on point, which is frowned upon in the CAS docs since the client gains access to usernames + passwords. But it's also a-nice-to-have if you're building an internal app that is entirely in your control.

    require 'casual'
    casual = Casual::Client.new(:server_path => 'local-cas-server'
                                :port => 443, # defaults to 443 (SSL)
                                :callback_url => 'http://your.example.com')
    casual.authenticate('holman','super_secret_password')
      # => returns 'holman' if I'm logged in, or nil if not

### Simulate traditional CAS authentication
This is closer to the normal CAS authentication process. It requires that you send the user off to your CAS login page to transfer tickets between your app and the CAS server, so you can't just do it all in one request.

    require 'casual'
    casual = Casual::Client.new(:server_path => 'local-cas-server'
                                :port => 443, # defaults to 443 (SSL)
                                :callback_url => 'http://your.example.com')
    casual.authentication_url
      # returns URL your user should be redirected to
      # after CAS login, redirects you to +callback_url+ with ticket as param
    casual.user_login(ticket)
      # returns username if valid, nil if invalid
      
## Casual.

by [@holman](http://twitter.com/holman).
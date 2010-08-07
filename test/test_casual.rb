require 'helper'

class TestCasual < Test::Unit::TestCase

  def setup
    @client = Casual::Client.new(:hostname     => 'localhost',
                                 :path         => '/cas',
                                 :port         => '8080',
                                 :callback_url => 'http://localhost')
  end

  def test_authorization_url
    assert_equal @client.authorization_url,
      "https://localhost:8080/cas/login?service=http://localhost"
  end

  def test_user_login_success
    mock(@client).authenticate_ticket.with('GOLDEN_TICKET_LOL') {
      '<cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">'+
      '<cas:authenticationSuccess><cas:user>holman</cas:user></cas:authenticationSuccess>'+
      '</cas:serviceResponse>'
    }
    assert_equal @client.user_login('GOLDEN_TICKET_LOL'), 'holman'
  end

  def test_user_login_fail
    mock(@client).authenticate_ticket.with('GOLDEN_TICKET_FAIL') {
      '<cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">'+
      '<cas:authenticationFailure code="INVALID_TICKET">Ticket \'GOLDEN_TICKET_FAIL\' not recognized.'+
      '</cas:authenticationFailure></cas:serviceResponse>'
    }
    assert_equal @client.user_login('GOLDEN_TICKET_FAIL'), nil
  end

  def test_authenticate_success
    connection_mock = mock('').post.with_any_args {
      [Net::HTTPSuccess.new('','200',''), '<div class="messagebox confirmation">You have successfully logged in.</div>']
    }
    mock(@client).connection { connection_mock }
    mock(@client).acquire_ticket { 'a_ticket' }
    assert_equal @client.authenticate('holman','lolsecret'), 'holman'
  end
end
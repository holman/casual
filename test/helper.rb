require 'rubygems'
require 'test/unit'
require 'redgreen'
require 'rr'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'casual'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
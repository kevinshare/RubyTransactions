ENV['RACK_ENV'] = 'test'

require './app'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # THE DOCS FOR PLAID EXPLAIN THAT PUBLIC TOKEN IS SENT VIA CLIENT SIDE LOGIN. 
  # AS A RESULT, WRITING MEANINGFUL TESTS WITHOUT PUBLIC TOKEN CREATION ABILITY
  # IS NEARLY IMPOSSIBLE. PUBLIC TOKENS RELY ON ACCESS TOKENS FOR CREATION AND 
  # VICE VERSA.


  #  def test_index_response_is_ok
  #   get '/'
  #   assert last_response.ok?
  #   assert_equal last_response.body, 'All responses are OK'
  # end

  # def set_request_headers
  #   header 'Accept-Charset', 'utf-8'
  #   get '/'
  #   assert last_response.ok?
  #   assert_equal last_response.body, 'All responses are OK'
  # end

  # def test_it_includes_clearbit_data
  #   get '/filteredTransactions'
  #   clear_data_piece = last_response.body[0].clearbit.name
  #   assert_equal 'string', clear_data.class
  # end
end
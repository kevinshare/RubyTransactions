ENV['KEY'] = 'KEY'
require 'date'
require 'sinatra'
require 'plaid'
require 'clearbit'
require 'HTTParty'
require 'pry'


set :public_folder, File.dirname(__FILE__) + '/public'

client = Plaid::Client.new(env: :sandbox,
                           client_id: ENV['PLAID_CLIENT_ID'],
                           secret: ENV['PLAID_SECRET'],
                           public_key: ENV['PLAID_PUBLIC_KEY'])

access_token = nil

auth = {:username => "KEY", :password => ""} 

get '/' do
  erb :index
end

post '/get_access_token' do
  puts params['public_token']
  exchange_token_response = client.item.public_token.exchange(params['public_token'])
  access_token = exchange_token_response['access_token']
  item_id = exchange_token_response['item_id']
  puts "access token: #{access_token}"
  puts "item id: #{item_id}"
  exchange_token_response.to_json
end

get '/transactions' do
  now = Date.today
  thirty_days_ago = (now - 50)
  results = []
  begin
    transactions_response = client.transactions.get(access_token, thirty_days_ago, now)
  rescue Plaid::ItemError => e
    transactions_response = { error: {error_code: e.error_code, error_message: e.error_message}}
  end
  transactions_response.transactions.each do |item| 
    name = item.name
    clearbit_response = HTTParty.get("https://autocomplete.clearbit.com/v1/companies/suggest?query=#{name}/", :basic_auth => auth, format: :plain)
    bitAdded = item.to_h.merge(clearbit: JSON.parse(clearbit_response))
    stringifiedItem = bitAdded.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}
    results.push(stringifiedItem)
  end
  content_type :json
  results.to_json
end

get '/filteredTransactions' do
  now = Date.today
  thirty_days_ago = (now - 50)
  filtered_transactions = []
  begin
    transactions_response = client.transactions.get(access_token, thirty_days_ago, now)
  rescue Plaid::ItemError => e
    transactions_response = { error: {error_code: e.error_code, error_message: e.error_message}}
  end
  transactions = transactions_response.transactions
  transactions.each_with_index do |item, i|
    valueToCheck = item.name.split
    otherValues = transactions.values_at(0..(i - 1), (i + 1)...transactions.length)
    otherValues.each do |comparison|
      if comparison.name.include? valueToCheck[0]
        name = item.name
        clearbit_response = HTTParty.get("https://autocomplete.clearbit.com/v1/companies/suggest?query=#{name}/", :basic_auth => auth, format: :plain)
        bitAdded = item.to_h.merge(clearbit: JSON.parse(clearbit_response))
        stringifiedItem = bitAdded.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}
        filtered_transactions.push(stringifiedItem)
      end
    end
  end
  content_type :json
  filtered_transactions.to_json
end

get '/create_public_token' do
  public_token_response = client.item.public_token.exchange(access_token)
  content_type :json
  public_token_response.to_json
end

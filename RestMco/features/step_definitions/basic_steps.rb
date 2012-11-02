require 'json'
require 'net/http'
require 'pp'
require 'rspec/expectations' 
require 'uri'

RESTSRV = 'http://localhost/mcollective'

When /I call ([A-z_]*) ([A-z_]*)/ do |agent, action|
    @agent  = agent
    @action = action
end

When /the Parameters are/ do |table|
  @params = { 'parameters' => table.hashes.first }
end

When /the target is random/ do
  @limit = { 'limit' => { 'targets' => 1, 'method' => 'random' }}
end

When /the Identity of the target is ([A-z0-9_\-\.]+)/ do |id|
  @identity = { 'identity' => [ id ] } 
end

When /^a Fact criteria is (.+)/ do |fact|
  @fact = { 'fact' => [ fact ] }
end

When /^a Class criteria is ([A-z0-9:\-]+)/ do |cname|
  @class = { 'class' => [ cname ] }
end

When /^a Compound criteria is (.+)/ do |compound|
  @class = { 'compound' => compound }
end

When /I query the REST server/ do
  url =  "#{RESTSRV}/#{@agent}/#{@action}/"
  uri = URI.parse(url)
  @http = Net::HTTP.new(uri.host, uri.port)
  @request = Net::HTTP::Post.new(uri.request_uri)
  filters = { 'filters' => {} }
  body    = Hash.new
  body.merge!(@limit)    if @limit
  body.merge!(@params)   if @params
  filters['filters'].merge!(@identity) if @identity
  filters['filters'].merge!(@fact)     if @fact
  filters['filters'].merge!(@class)    if @class
  body.merge!(filters)   if filters['filters']
  unless body.empty?
    @request.body = JSON.dump(body)
    #@request["Content-Type"] = "application/json, charset=UTF-8"
    @request["Content-Type"] = "application/json"
  end
  @response = @http.request(@request) 
end

Then /^the StatusMsg is OK$/ do
  j = JSON.load(@response.body)
  #pp j
  #j.each { |i| puts "\nResponse from : #{i['sender']}" }
  j.first['statusmsg'].should == 'OK'
end


Then /^I should get an hexadecimal jobid$/ do
  j = JSON.load(@response.body)
  @jobid = j.first['data']['jobid']
  @jobid.should =~ /^[a-f0-9]+$/
end

Then /^I should get a task in one of those states :$/ do |tlist|
  regexp = tlist.raw.flatten.join(sep='|')
  url =  "#{RESTSRV}/scheduler/query/"
  params = { 'parameters' => { :output => 'yes', :jobid => @jobid } }
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  @request = Net::HTTP::Post.new(uri.request_uri)
  filters = { 'filters' => {} }
  body    = Hash.new
  body.merge!(@limit)   if @limit
  body.merge!(params)   if params
  filters['filters'].merge!(@identity) if @identity
  filters['filters'].merge!(@fact)     if @fact
  filters['filters'].merge!(@class)    if @class
  body.merge!(filters)  if filters['filters']
  unless body.empty?
    @request.body = JSON.dump(body)
    #@request["Content-Type"] = "application/json, charset=UTF-8"
    @request["Content-Type"] = "application/json"
  end
  response = @http.request(@request) 
  j = JSON.load(response.body)
  state = j.first['data']['state']
  state.should =~ /#{regexp}/
end

Then /I should eventually get a good task result/ do
  state = nil
  statuscode = nil
  eventually {
      response = @http.request(@request) 
      @j = JSON.load(response.body)
      state = @j.first['data']['state']
      state.should =~ /finished/
  }
  statuscode =@j.first['data']['statuscode']
  statuscode.should == 0
end

Then /I should get a 'pong'/ do
  result = @j.first['data']['data']['pong']
  result.class.should == 0.class 
end


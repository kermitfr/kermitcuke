require 'rspec/expectations' 
require 'mcollective'
require 'pp'

MCO_CONFIG = '/etc/mcollective/client.cfg'
MCO_TIMEOUT = 5
MCO_DISCOVTMOUT = 1
MCO_DEBUG = false
MCO_COLLECTIVE = nil

Given /the Agent is ([A-z_]*)/ do |agent|
  @agent = agent
  @mc = MCollective::RPC::Client.new( agent, \
         :configfile => MCO_CONFIG,
         :options => {
             :verbose      => false,
             :progress_bar => false,
             :timeout      => MCO_TIMEOUT,
             :config       => MCO_CONFIG,
             :filter       => { "agent" => [], "identity" => [] },
             :collective   => MCO_COLLECTIVE,
             :disctimeout  => MCO_DISCOVTMOUT } )
end

Given /the Action is ([A-z_]*)/ do |action|
  @action = action
end

Given /the Parameters are/ do |table|
  myhash = table.hashes.first
  # convert string keys to symbols
  @arguments = Hash[myhash.map{|(k,v)| [k.to_sym,v]}]
end

Given /the target is random/ do
  @mc.limit_targets = 1
  @mc.limit_method = :random
end

Given /the Identity of the target is ([A-z0-9\.]*)/ do |id|
  @mc.identity_filter id
end

When /I call MCollective/ do
  @out = @mc.send(@action, @arguments)
end

Then /I should get an hexadecimal jobid/ do
  @jobid = @out.first.results[:data][:jobid]
  @jobid.should =~ /^[a-f0-9]+$/
end

Then /I should get a task in one of those states :/ do |tlist|
  regexp = tlist.raw.flatten.join(sep='|')
  @out = @mc.send('query', :jobid=>@jobid, :output=>'yes')
  state = @out.first.results[:data][:state]
  state.should =~ /#{regexp}/
end

Then /the StatusMsg is ([A-z_]*)/ do |statusmsg|
  @out = @mc.send(@action, @arguments)
  statusmsg.should == @out.first.results[:statusmsg]
end

Then /I should get a good task result within (\d+) seconds/ do |delay|
  sleep delay.to_i
  @out = @mc.send('query', :jobid=>@jobid, :output=>'yes')
  state = @out.first.results[:data][:state]
  statuscode = @out.first.results[:data][:statuscode]
  state.should =~ /finished/
  statuscode.should == 0
end



require 'rspec/expectations' 
require 'mcollective'

MCO_CONFIG = '/etc/mcollective/client.cfg'
MCO_TIMEOUT = 5
MCO_DISCOVTMOUT = 1
MCO_DEBUG = false
MCO_COLLECTIVE = nil

When /I use ([A-z_]*) ([A-z_]*)/ do |agent, action|
  @agent = agent
  @action = action
  @mc = MCollective::RPC::Client.new( agent, \
         :configfile => MCO_CONFIG,
         :options => {
             :verbose      => false,
             :progress_bar => false,
             :timeout      => MCO_TIMEOUT,
             :config       => MCO_CONFIG,
             #:filter       => { "agent" => [], "identity" => [] },
             :filter       => MCollective::Util.empty_filter,
             :collective   => MCO_COLLECTIVE,
             :disctimeout  => MCO_DISCOVTMOUT } )
end

When /the Parameters are/ do |table|
  myhash = table.hashes.first
  # convert string keys to symbols
  @arguments = Hash[myhash.map{|(k,v)| [k.to_sym,v]}]
end

When /the target is random/ do
  @mc.limit_targets = 1
  @mc.limit_method = :random
end

When /the Identity of the target is ([A-z0-9\.]*)/ do |id|
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

Then /I should eventually get a good task result/ do
  state = nil 
  statuscode = nil
  eventually {
      @out = @mc.send('query', :jobid=>@jobid, :output=>'yes')
      state = @out.first.results[:data][:state]
      state.should =~ /finished/
  }
  statuscode = @out.first.results[:data][:statuscode]
  statuscode.should == 0
end

Then /I should eventually get an inventory/ do
  inventoryfolder = '/var/lib/kermit/queue/kermit.inventory/'
  ntime=Time.now.to_i
  res = Array.new
  eventually {
      newi = File.basename(@out.first.results[:data][:result])
      inventories = Dir["#{inventoryfolder}/*.json"].map{ |f| File.basename f }.join("\n")
      res = inventories.scan(/^.*#{newi}$/)
      res.should_not be_empty
  }
  ctime=File.ctime("#{inventoryfolder}/#{res.first}").to_i
  subst=ntime-ctime
  subst.should <= 10 
end

Then /I should eventually get a log/ do
  logfolder = '/var/lib/kermit/queue/kermit.log/'
  res = Array.new 
  eventually {
    newlog = File.basename(@out.first.results[:data]['logfile'])
    logs = Dir["#{logfolder}/*"].map{ |f| File.basename f }.join("\n")
    res = logs.scan(/^.*#{newlog}$/)
    res.should_not be_empty
  }
end


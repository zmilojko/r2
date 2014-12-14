class SidekiqCtrl
  def self.defaultQueue 
    if ENV['refinder_queue'].blank?
      'default'
    else
      ENV['refinder_queue']
    end
  end

  def self.try_kill_sidekiq warn_if_off: false
    # Stop sidekick if it exists, but to mark if it did exists, because it really shoudn't have
    result = `cd #{Rails.root} ; sidekiqctl stop tmp/pids/sidekiq.pid`
    puts "WARNING: Sidekiq was already running. It is now shutdown." if warn_if_off and not result[/does not exist/]
  end

  def self.do_start_sidekiq
    # Now start sidekiq, as it should start
    `cd #{Rails.root} ; bundle exec sidekiq -d -L log/sidekiq.log -q #{defaultQueue} -C #{Rails.root.join 'config', 'sidekiq.yml'}`
    puts "Started Sidekiq for queue #{defaultQueue}"
  end
end
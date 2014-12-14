require 'sidekiq_ctrl'

if Mongoid.configured?
  Mongoid.configure.sessions[:default][:database] = "r2_#{SidekiqCtrl.defaultQueue.gsub("default","development")}"
  puts "Mongoid: using database #{Mongoid.configure.sessions[:default][:database]}"
else
  raise "Cannot configure Mongoid because it is not loaded yet"
end


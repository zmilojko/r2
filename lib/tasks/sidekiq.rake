require 'sidekiq_ctrl'

namespace :sidekiq do
  desc "start sidekiq, killing it if it already runs"
  task :start do
    SidekiqCtrl.try_kill_sidekiq warn_if_off: true
    SidekiqCtrl.do_start_sidekiq
  end
  desc "stopping sidekiq gracefully"
  task :stop do
    SidekiqCtrl.try_kill_sidekiq
  end
end

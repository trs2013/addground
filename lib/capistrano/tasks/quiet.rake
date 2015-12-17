namespace :deploy do
  desc 'Stop Sidekiq job processing'
  task :quiet do
    on roles :all do
      begin
        execute :sudo, :pkill, "--signal USR1 -f '^sidekiq'"
      rescue SSHKit::Command::Failed
        puts "No workers running"
      end
    end
  end
end
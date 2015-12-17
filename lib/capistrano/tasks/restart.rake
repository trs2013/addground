namespace :deploy do
  desc 'Commands for unicorn application'
  task :restart do

    on roles :all do
      begin
        execute :sudo, :restart, :feedbin
      rescue SSHKit::Command::Failed
        execute :sudo, :start, :feedbin
      end
    end

    on roles :web do
      begin
        execute :sudo, "/etc/init.d/unicorn", :reload
      rescue SSHKit::Command::Failed, SSHKit::Runner::ExecuteError
        execute :sudo, "/etc/init.d/unicorn", :start
      end
    end

    on roles :worker do
      begin
        execute :sudo, :restart, :workers
      rescue SSHKit::Command::Failed
        execute :sudo, :start, :workers
      end

      begin
        execute :sudo, :restart, :workers_slow
      rescue SSHKit::Command::Failed
        execute :sudo, :start, :workers_slow
      end
    end

  end
end

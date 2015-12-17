namespace :foreman do
  desc 'Commands for unicorn application'
  task :export do

    on roles :all do
      within release_path do
        execute "sudo /usr/local/rbenv/bin/rbenv", :exec, :bundle, :exec, :foreman, :export, "--app #{fetch(:application)} --user #{fetch(:user)} --concurrency clock=1,sidekiq_web=1 --log #{shared_path}/log upstart /etc/init"
      end
    end

  end
end

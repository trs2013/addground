lock "3.4.0"

set :user, 'app'
set :application, "feedbin"
set :repo_url, "git@github.com:feedbin/#{fetch(:application)}.git"
set :deploy_to, "/srv/apps/#{fetch(:application)}"

set :bundle_jobs, 4
set :rbenv_type, :system
set :rbenv_ruby, "2.2.3"
# set :log_level, :info
set :default_env, {
  bash_env: "/home/app/feedbin-env/current/env"
}

before "deploy", "deploy:quiet"
after "deploy:published", "foreman:export"
after "deploy:finished", "deploy:restart"


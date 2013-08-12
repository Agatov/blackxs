# config/deploy.rb
# We're using RVM on a server, need this.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3'
set :rvm_type, :user

# Bundler tasks
require 'bundler/capistrano'

set :application, "blackxs"
set :repository,  "git@github.com:stulentsev/blackxs.git"

set :scm, :git

# do not use sudo
set :use_sudo, false
set(:run_method) { use_sudo ? :sudo : :run }

# This is needed to correctly handle sudo password prompt
default_run_options[:pty] = true

set :user, "root"
set :group, user
set :runner, user

set :host, "#{user}@188.120.246.84" # We need to be able to SSH to that box as this user.
role :web, host
role :app, host

set :env, :production

# Where will it be located on a server?
set :deploy_to, "/apps#{application}"
set :unicorn_conf, "#{deploy_to}/shared/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/tmp/pids/unicorn.pid"

# Unicorn control tasks
namespace :deploy do
  task :restart do
    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{env} -D; fi"
  end
  task :start do
    run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end
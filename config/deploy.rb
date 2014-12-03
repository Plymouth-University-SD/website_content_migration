set :stages, %w(staging pre-prod)
set :default_stage, "staging"

set :application, 'plym_migration'
set :user, 'plym_migration'
set :repository, 'git@github.com:Plymouth-University-SD/website_content_migration.git'
set :ssh_options, { :forward_agent => true }
set :deploy_via, :remote_cache
set :use_sudo, false

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to,  "/home/#{user}/#{application}"
set :scm, :git

# Use login shell so that we have access to ruby via rbenv
set :default_shell, 'bash -l'

begin
  require 'capistrano/ext/multistage'
rescue LoadError
  puts "Could not load capistrano multistage extension.  Make sure you have installed the capistrano-ext gem"
end

require 'bundler/capistrano'
# see https://github.com/mperham/sidekiq/wiki/Deployment

set :bundle_without, [:development, :test]

default_run_options[:pty] = true

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  after "deploy:finalize_update", "deploy:symlink_configs"
  task :symlink_configs do
    run "ln -fs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end

  namespace :db do
    after "deploy:migrate", "deploy:db:seed"
    desc "Seed the database"
    task :seed, :roles => :db, :only => { :primary => true } do
      command =  "cd #{latest_release} && "
      command += "bundle exec rake RAILS_ENV=#{rails_env} db:seed"
      run command
    end
  end
end

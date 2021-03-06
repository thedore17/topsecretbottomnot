require 'bundler/capistrano'

set :application, "nyte.shrub.ca"
set :repository,  "git@github.com:thedore17/topsecretbottomnot.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "shrub.ca"                          # Your HTTP server, Apache/etc
role :app, "shrub.ca"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :domain, "shrub.ca"
set :use_sudo, false
set :keep_releases, 5


set :deploy_via, :remote_cache
set :deploy_to, "/data/sites/#{application}"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_config_files do
	run "#{ try_sudo } ln -sf #{ deploy_to }/shared/keys.yml #{ release_path }/config/keys.yml"
  end
end

before "deploy:assets:precompile", "deploy:symlink_config_files"
after "deploy", "deploy:cleanup"


# config valid for current version and patch releases of Capistrano
lock "~> 3.14.0"

# define multiple deployments
set :stages, %w(production staging)
set :default_stage, 'staging'

set :application, "projector"
set :repo_url, "https://github.com/Kv065RubySSTeam/projector.git"

set :user, 'ubuntu'
set :app_name, 'projector'
set :pty,  false

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", ".bundle", "public/system", "public/uploads"

# Default deploy_to directory is /var/www/my_app_name
set :keep_releases, 2

# Default value for :linked_files is [] and  linked_dirs is []
append :linked_files, "config/database.yml", "config/master.key"
set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Skip migration if files in db/migrate were not modified
# This command requires loading capistrano/rails in Capfile
set :conditionally_migrate, true

# Set default ruby version
set :rvm_ruby_version, '2.5.5'

# Remove gems no longer used to reduce disk space used
# This command requires loading capistrano/bundler in Capfile
after 'deploy:published', 'bundler:clean'

# leave only 2 releases
after "deploy", "deploy:cleanup"


set :rails_env, 'production'

# for sideqik
# set :sidekiq_role, :app
# set :sidekiq_config, "#{current_path}/config/sidekiq.yml"
# set :sidekiq_env, 'production'


# after 'deploy:publishing', 'deploy:restart'
# ​
# namespace :deploy do
#   task :restart do
#     invoke 'nginx:setup'
#     invoke 'nginx:reload'
#   end
# end

# set :application, "#{fetch(:app_name)}_#{fetch(:stage)}"
# set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# set :linked_files, fetch(:linked_files, []).push('config/database.yml')
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
# ​
# ​
# after 'deploy:publishing', 'deploy:restart'
# ​
# namespace :deploy do
#   task :restart do
#     invoke 'unicorn:restart'
#     invoke 'nginx:setup'
#     invoke 'nginx:reload'
#   end
# end
# ​
namespace :db do
  task :reset do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env)  do
          execute :rake, 'db:drop'
          execute :rake, 'db:create'
          execute :rake, 'db:migrate'
        end
      end
    end
  end
end
# ​
# namespace :nginx do
#   desc 'Setup nginx configuration'
#   task :setup do
#     on roles :web do
#       execute :cp, "#{release_path}/config/nginx/#{fetch(:stage)}.conf", "#{shared_path}/config/nginx/#{fetch(:application)}"
#       sudo :ln, '-fs', "#{shared_path}/config/nginx/#{fetch(:application)}", "/etc/nginx/sites-enabled/#{fetch(:application)}"
#     end
#   end
# ​
#   %w[start stop restart reload].each do |command|
#     desc "#{command.capitalize} nginx service"
#     task command.to_sym do
#       on roles(:web) do |host|
#         sudo "service nginx #{command}"
#         info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
#       end
#     end
#   end
# end

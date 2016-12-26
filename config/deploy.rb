lock '3.6.1'
# Sidekiq known bug - https://github.com/seuros/capistrano-sidekiq#usage
set :pty,  false
set :application, 'gobierto'
set :repo_url, 'git@github.com:PopulateTools/gobierto-dev.git'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', '.rbenv-vars', "config/settings/#{fetch(:stage)}.yml")
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/cache')
set :rbenv_type, :user
set :rbenv_ruby, '2.3.1'
set :rbenv_path, '/home/ubuntu/.rbenv'
set :passenger_restart_with_touch, true
set :sidekiq_options_per_process, ["-q default -q user_verifications -q mailers"]


namespace :deploy do
  desc "Copy example secrets"
  task :copy_secrets_file do
    on roles(:app) do
      execute "cp #{release_path}/config/secrets.yml.example #{release_path}/config/secrets.yml"
    end
  end
end

namespace :deploy do
  after "deploy:symlink:linked_files", "deploy:copy_secrets_file"
end

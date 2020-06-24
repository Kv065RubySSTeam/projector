# frozen_string_literal: true

set :stage, :staging
set :rails_env, :staging

set :branch, 'master'

server '3.16.14.1', user: 'ubuntu', roles: %w[app db web]

set :bundle_without, %w[development test].join(' ')

set :deploy_to, "/home/deploy/#{fetch :application}/staging"

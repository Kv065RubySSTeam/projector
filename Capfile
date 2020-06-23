# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
#
# require "capistrano/scm/hg"
# install_plugin Capistrano::SCM::Hg
# or
# require "capistrano/scm/svn"
# install_plugin Capistrano::SCM::Svn
# or
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# require "capistrano/rails"
require "capistrano/passenger"
require "capistrano/rvm"
require "capistrano/bundler"
require 'capistrano/rails/migrations'
require 'capistrano/local_precompile'
# require 'capistrano/rails/assets'

# Default sidekiq tasks
require 'capistrano/sidekiq'
# require 'whenever/capistrano'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

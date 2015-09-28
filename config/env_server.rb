require 'bundler'
Bundler.require
Oj.default_options = { mode: :compat }

path = File.expand_path "../../", __FILE__
APP_PATH = path

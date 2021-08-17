# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

# Loading all tests check file test_load_all
require_relative 'test_load_all'

def wipe_database
  app.DB[:jobs].delete
  app.DB[:companies].delete
end

# What does this mean? DATA = {} creating an empty hash!
DATA = {} # rubocop:disable Style/MutableConstant
DATA[:jobs] = YAML.safe_load File.read('app/db/seeds/jobs_seeds.yml')
DATA[:companies] = YAML.safe_load File.read('app/db/seeds/companies_seeds.yml')
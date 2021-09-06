# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'
require 'logger'
require './app/lib/secure_db'

module Interna
  # Configuration for the API
  class Api < Roda
    plugin :environments

    Figaro.application = Figaro::Application.new(
      environment: environment,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    # Making the 'environment variables' accessible to other classes
    def self.config() = Figaro.env
    
    # Logger setup
    LOGGER = Logger.new($stderr)
    def self.logger() = LOGGER

    # Connecting database Sequel.connect, DATABASE_URL is a local url yml
    DB = Sequel.connect(ENV.delete('DATABASE_URL'))
    # Making the database accessible to other classes
    def self.DB() = DB # New Ruby style to define methods in one line

    configure :development, :test do
      require 'pry'
      logger.level = Logger::ERROR
    end
  end
end

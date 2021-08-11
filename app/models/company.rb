# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Interna
  STORE_DIR = 'app/db/store' # Constant value

  # Holds a full secret company
  class Company
    # Crete a new company by passing in hash of attributes?
    def initialize(new_company)
      @id = new_company['id'] || new_id # Method for new id enconded in base64 below
      @comname        = new_company['comname']
      @description    = new_company['description']
      @content        = new_company['content']
    end

    attr_reader :id, :comname, :description, :content

    def to_json(options = {})
      JSON(
        {
          type: 'company',
          id: id,
          comname: comname,
          description: description,
          content: content
        },
        options
      )
    end

    # Company storage must be setup once when application runs
    def self.setup
      Dir.mkdir(Interna::STORE_DIR) unless Dir.exist? Interna::STORE_DIR
    end

    # Stores company in company storage
    def save
      File.write("#{Interna::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one company
    def self.find(find_id)
      company_file = File.read("#{Interna::STORE_DIR}/#{find_id}.txt")
      Company.new JSON.parse(company_file)
    end

    # Query method to retrieve index of all companies
    def self.all
      Dir.glob("#{Interna::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(Interna::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_json
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end

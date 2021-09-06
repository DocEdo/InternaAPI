# frozen_string_literal: true

require 'json'
require 'sequel'

module Interna
  # Modeling a secret job
  class Job < Sequel::Model
    many_to_one :company

    plugin :uuid, field: id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :jobname, :description, :content

    # Securing getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end
    
    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'job',
            attributes: {
              id: id,
              jobname: jobname,
              description: description,
              content: content
            }
          },
          included: {
            company: company
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

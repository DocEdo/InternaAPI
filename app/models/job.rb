# frozen_string_literal: true

require 'json'
require 'sequel'

module Interna
  # Modeling a secret job
  class Job < Sequel::Model
    many_to_one :company

    plugin :timestamps

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

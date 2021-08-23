# frozen_string_literal: true

require 'json'
require 'sequel'

module Interna
  # Models a Company
  class Company < Sequel::Model
    one_to_many :jobs
    plugin :association_dependencies, jobs: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'company',
            attributes: {
              id: id,
              name: name,
              description: description
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

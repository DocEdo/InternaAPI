# frozen_string_literal: true

require 'roda'
require 'json'

# Go back one folder .. and models/company
require_relative '../models/company'

module Interna
  # Web controller for Interna API
  # < Roda means inheritance of a Roda class
  class Api < Roda
    plugin :environments
    plugin :halt

    # Method that belongs to environments, it will run any code before the API runs

    configure do
      Company.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json' # Content type is defined as json here, why?

      routing.root do
        response.status = 200
        { message: 'InternaAPI up at /api/v1' }.to_json # The last bit of the response is the message (body HTTP)
      end

      # API routing block (Roda management of API)
      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'companies' do
            # GET api/v1/companies/[id]
            routing.get String do |id|
              response.status = 200
              Company.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Company not found' }.to_json
            end

            # GET api/v1/companies
            routing.get do
              response.status = 200
              output = { company_ids: Company.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/companies
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_com = Company.new(new_data)

              if new_com.save
                response.status = 201
                { message: 'Company saved', id: new_com.id }.to_json
              else
                routing.halt 400, { message: 'Could not save company' }.to_json
              end
            end
          end
        end
      end
    end
  end
end

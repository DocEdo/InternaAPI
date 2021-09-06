# frozen_string_literal: true

require 'roda'
require 'json'

# Go back one folder .. and models/job
# require_relative '../models/job'

module Interna
  # Web controller for Interna API
  # < Roda means inheritance of a Roda class
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json' # Content type is defined as json here, why?

      routing.root do
        { message: 'InternaAPI up at /api/v1' }.to_json # The last bit of the response is the message (body HTTP)
      end

      # API routing block (Roda management of API)
      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'companies' do
          @comp_route = "#{@api_root}/companies"

          routing.on String do |comp_id|
            routing.on 'jobs' do
              @job_route = "#{@api_root}/companies/#{comp_id}/jobs"

              # GET api/v1/companies/[comp_id]/jobs/[job_id]
              routing.get String do |job_id|
                job = Job.where(company_id: comp_id, id: job_id).first
                job ? job.to_json : raise('Job not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/companies/[comp_id]/jobs
              routing.get do
                output = { data: Company.first(id: comp_id).jobs }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Jobs not found'
              end

              # POST api/v1/companies/[comp_id]/jobs
              routing.post do
                new_data = JSON.parse(routing.body.read)
                comp = Company.first(id: comp_id)
                new_job = comp.add_job(new_data)
                raise 'Could not save job.' unless new_job

                response.status = 201
                response['Location'] = "#{@job_route}/#{new_job.id}"
                { message: 'Job saved.', data: new_job }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_job.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end
            
            # GET api/v1/companies/[comp_id]
            routing.get do
              comp = Company.first(id: comp_id)
              comp ? comp.to_json : raise('Company not found.')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/companies
          routing.get do
            output = { data: Company.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find companies.' }.to_json
          end

          # POST api/v1/companies
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_comp = Company.new(new_data)
            raise('Could not save company.') unless new_comp.save

            response.status = 201
            response['Location'] = "#{@comp_route}/#{new_comp.id}"
            { message: 'Company saved', data: new_comp }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes.' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: "Unknown server error." }.to_json
          end
        end
      end
    end
  end
end

=begin
            # GET api/v1/companies/[comp_id]
            routing.get do
              comp = Company.first(id: comp_id)
              comp ? comp.to_json : raise('Company not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/companies
          routing.get do
            output = { data: Company.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find companies.' }.to_json
          end

          # POST api/v1/companies
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_comp = Company.new(new_data)
            raise('Could not save company.') unless new_comp.save

            response.status = 201
            response['Location'] = "#{@comp_route}/#{new_comp.id}"
            { message: 'Company saved', data: new_comp }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
=end
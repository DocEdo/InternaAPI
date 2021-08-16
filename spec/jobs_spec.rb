# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test All Jobs Manipulations' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:companies].each do |company_data|
      Interna::Company.create(company_data)
    end
  end

  it 'NICE: All jobs are listed.' do
    comp = Interna::Company.first
    DATA[:jobs].each do |job|
      comp.add_job(job)
    end
    
    get "api/v1/companies/#{comp.id}/jobs"
    _(last_response.status).must_equal 200
    
    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'NICE: All details in a single job.' do
    job_data = DATA[:jobs][1]
    comp = Interna::Company.first
    job = comp.add_job(job_data).save

    get "/api/v1/companies/#{comp.id}/jobs/#{job.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal job.id
    _(result['data']['attributes']['filename']).must_equal job_data['jobname']
  end

  it 'BUMPY: Error if there is an unknown request.' do
    comp = Interna::Company.first
    get "/api/v1/companies/#{comp.id}/jobs/rastakhan"

    _(last_response.status).must_equal 404
  end

  it 'NICE: Create new jobs.' do
    comp = Interna::Company.first
    job_data = DATA[:jobs][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/companies/#{comp.id/jobs}", job_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    job = Interna::Job.first

    _(created['id']).must_equal job.id
    _(created['jobname']).must_equal job_data['jobname']
    _(created['description']).must_equal job_data['description']
  end
end
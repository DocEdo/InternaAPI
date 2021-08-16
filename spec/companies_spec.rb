# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test All Companies Manipulations' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'NIVR: List all companies.' do
    Interna::Company.create(DATA[:companies][0]).save
    Interna::Company.create(DATA[:companies][1]).save

    get 'api/v1/companies'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'NICE: Details for every company.' do
    existing_comp = DATA[:companies][1]
    Interna::Company.create(existing_comp).save
    id = Interna::Company.first.id

    get "/api/v1/companies/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_comp['name']
  end

  it 'BUMPY: Error for unknown request.' do
    get '/api/v1/companies/leeeeroy'

    _(last_response.status).must_equal 404
  end

  it 'NICE: Create companies.' do
    existing_comp = DATA[:companies][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/companies', existing_comp.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    comp = Interna::Company.first

    _(created['id']).must_equal comp.id
    _(created['name']).must_equal existing_comp['name']
  end
end
# frozen_string_literal: true

require 'json'
require 'sequel'

module Interna
  # Models a project
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
              name: name
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end

=begin
 module Interna
   STORE_DIR = 'app/db/store' # Constant value

   # Holds a full secret job
   class Job
     # Crete a new job by passing in hash of attributes?
     def initialize(new_job)
       @id = new_job['id'] || new_id # Method for new id enconded in base64 below
       @jobname        = new_job['jobname']
       @description    = new_job['description']
       @content        = new_job['content']
     end

     attr_reader :id, :jobname, :description, :content

     def to_json(options = {})
       JSON(
         {
           type: 'job',
           id: id,
           jobname: jobname,
           description: description,
           content: content
         },
         options
       )
     end

     # Job storage must be setup once when application runs
     def self.setup
       # .mkdir method will create the storage directory as a String (we can optionally change to interger but why?)
       Dir.mkdir(Interna::STORE_DIR) unless Dir.exist? Interna::STORE_DIR
     end

     # Stores job in job storage
     def save
       File.write("#{Interna::STORE_DIR}/#{id}.txt", to_json)
     end

     # Query method to find one job
     def self.find(find_id)
       job_file = File.read("#{Interna::STORE_DIR}/#{find_id}.txt")
       Job.new JSON.parse(job_file)
     end

     # Query method to retrieve index of all jobs
     def self.all
       Dir.glob("#{Interna::STORE_DIR}/*.txt").map do |file|
         # Regexp.quote( aString ) -> aNewString
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
=end
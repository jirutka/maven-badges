require 'sinatra'
require 'httparty'

class Sonatype
  include HTTParty

  base_uri 'repository.sonatype.org'
  default_params :r => 'central-proxy'
  headers 'Accept' => 'application/json'
  format :json

  class << self
    def last_artifact_version(group_id, artifact_id, version='LATEST')
      resp = get('/service/local/artifact/maven/resolve', query: {g: group_id, a: artifact_id, v: version})
      
      raise HTTParty::ResponseError.new(resp) if resp.code != 200
      resp.parsed_response['data']['version']
    end
  end
end

class Shields
  include HTTParty

  base_uri 'img.shields.io'

  def self.badge_image(subject, status, color, format='svg')
    get("/badge/#{subject}-#{status}-#{color}.#{format}").body
  end
end

get '/' do
  "I'm alive!"
end

get '/artifact/:group_id/:artifact_id' do |group_id, artifact_id|
  content_type 'image/svg+xml'

  begin
    status = Sonatype.last_artifact_version(group_id, artifact_id)
    color = :brightgreen
  rescue HTTParty::ResponseError => e
    status = e.response.code == 404 ? 'unknown' : 'error'
    color = :red
  end

  Shields.badge_image 'Maven', status, color
end

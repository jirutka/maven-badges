require 'sinatra'
require_relative 'sonatype.rb'
require_relative 'shields.rb'

get '/' do
  "I'm alive!"
end

get '/artifact/:group_id/:artifact_id' do |group_id, artifact_id|
  content_type 'image/svg+xml'
  cache_control :public, :max_age => 3600

  begin
    status = Sonatype.last_artifact_version(group_id, artifact_id)
    color = :brightgreen
  rescue HTTParty::ResponseError => e
    status = e.response.code == 404 ? 'unknown' : 'error'
    color = :red
  end

  Shields.badge_image 'Maven', status, color
end

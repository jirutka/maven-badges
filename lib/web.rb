require 'sinatra'
require_relative 'sonatype'
require_relative 'shields'

DEFAULT_SUBJECT = 'maven central'
PROJECT_SITE = 'https://github.com/jirutka/maven-badges'

configure :production do
  disable :static
  before { cache_control :public, :max_age => 3600 }
end

get '/' do
  content_type :text
  "Nothing is here, see #{PROJECT_SITE}."
end

get '/maven-central/:group/:artifact/badge.?:format?' do |group, artifact, format|
  halt 415 unless ['svg', 'png'].include? format

  content_type format
  subject = params['subject'] || DEFAULT_SUBJECT

  begin
    version = Sonatype.last_artifact_version(group, artifact)
    color = :brightgreen
  rescue NotFoundError
    version = 'unknown'
    color = :lightgray
  end

  Shields.badge_image subject, version, color, format
end

error do
  content_type :text
  halt 500, "Something went wrong, please open an issue on #{PROJECT_SITE}/issues"
end
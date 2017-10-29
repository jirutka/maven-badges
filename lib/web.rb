require 'sinatra'
require_relative 'maven_central'
require_relative 'shields'

DEFAULT_SUBJECT = 'maven central'
DEFAULT_STYLE = 'default'
PROJECT_SITE = 'https://github.com/jirutka/maven-badges'

configure :production do
  disable :static
  before { cache_control :public, :max_age => 3600 }
end

get '/' do
  content_type :text
  "Nothing is here, see #{PROJECT_SITE}."
end

# Returns badge image with the artifact's last version number
get '/maven-central/:group/:artifact/badge.:format' do |group, artifact, format|
  halt 415 unless ['svg', 'png'].include? format

  content_type format
  subject = params['subject'] || DEFAULT_SUBJECT
  version = params[:version]

  begin
    if (defined?(version)).nil? # will now return true or false
      version = MavenCentral.last_artifact_version(group, artifact)
   else
      version = MavenCentral.defined_artifact_version(group, artifact, version)
    end
    color = :brightgreen
  rescue NotFoundError
    version = 'unknown'
    color = :lightgray
  end

  style = params[:style] || DEFAULT_STYLE

  Shields.badge_image(subject, version, color, format, style)
end

# Returns the artifact's last version number in plain text
get '/maven-central/:group/:artifact/last_version' do |group, artifact|
  content_type :text

  MavenCentral.last_artifact_version(group, artifact)
end

# Redirects to the artifact's page on search.maven.org
get '/maven-central/:group/:artifact/?' do |group, artifact|
  begin
    version = MavenCentral.last_artifact_version(group, artifact)
    redirect to MavenCentral.artifact_details_url(group, artifact, version)
  rescue NotFoundError
    redirect to MavenCentral.search_by_ga_url(group, artifact)
  end
end

error do
  content_type :text
  halt 500, "Something went wrong, please open an issue on #{PROJECT_SITE}/issues"
end
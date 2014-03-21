require 'httparty'

class Sonatype
  include HTTParty

  base_uri 'repository.sonatype.org'
  default_params :r => 'central-proxy'
  headers 'Accept' => 'application/json'
  format :json

  def self.last_artifact_version(group_id, artifact_id, version='LATEST')
    resp = get('/service/local/artifact/maven/resolve',
               query: {g: group_id, a: artifact_id, v: version})
    
    raise HTTParty::ResponseError.new(resp) if resp.code != 200
    resp.parsed_response['data']['version']
  end
end
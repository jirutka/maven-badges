require 'httparty'

class MavenCentral
  include HTTParty

  base_uri 'search.maven.org'
  default_params wt: 'json'
  headers 'Accept' => 'application/json'
  format :json

  def self.last_artifact_version(group_id, artifact_id)
    resp = get('/solrsearch/select', query: {
      q: %{g:"#{group_id}" AND a:"#{artifact_id}"}, rows: 1
    })
    raise HTTParty::ResponseError.new(resp) if resp.code != 200

    doc = resp.parsed_response['response']
    if doc['numFound'] > 0
      doc['docs'][0]['latestVersion']
    else
      raise NotFoundError
    end
  end
end

class NotFoundError < StandardError; end
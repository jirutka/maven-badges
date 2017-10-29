require 'httparty'
require 'uri'

class MavenCentral
  include HTTParty

  base_uri 'http://search.maven.org'
  default_params wt: 'json'
  headers 'Accept' => 'application/json'
  format :json

  # Requests the last version of the specified artifact.
  def self.last_artifact_version(group_id, artifact_id)
    resp = get('/solrsearch/select', query: {
      q: format_query(group_id, artifact_id), rows: 1
    })
    raise HTTParty::ResponseError.new(resp) if resp.code != 200

    doc = resp.parsed_response['response']
    if doc['numFound'] > 0
      doc['docs'][0]['latestVersion']
    else
      raise NotFoundError
    end
  end

     # Requests a specific version of the specified artifact.
  def self.defined_artifact_version(group_id, artifact_id, version)
    resp = get('/solrsearch/select', query: {
      q: format_query_with_version(group_id, artifact_id, version), rows: 1
    })
    raise HTTParty::ResponseError.new(resp) if resp.code != 200

    doc = resp.parsed_response['response']
    if doc['numFound'] > 0
      doc['docs'][0]['v']
    else
      raise NotFoundError
    end
  end

  # Returns URL of the web page with details about the specified artifact.
  def self.artifact_details_url(group_id, artifact_id, version)
    "#{base_uri}/#artifactdetails%7C#{group_id}%7C#{artifact_id}%7C#{version}%7C"
  end

  # Returns URL of the web page with search results for searching by the
  # artifact's coordinates.
  def self.search_by_ga_url(group_id, artifact_id)
    "#{base_uri}/#search%7Cga%7C1%7C#{format_query(group_id, artifact_id)}"
  end

  private

  def self.format_query(group_id, artifact_id)
    %{g:"#{group_id}" AND a:"#{artifact_id}"}
  end

  def self.format_query_with_version(group_id, artifact_id, version)
    %{g:"#{group_id}" AND a:"#{artifact_id}" AND v:"#{version}"}
  end
end

class NotFoundError < StandardError; end
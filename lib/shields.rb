require 'httparty'

class Shields
  include HTTParty

  REPLACEMENTS = {'_' => '__', ' ' => '_', '-' => '--' }

  base_uri 'img.shields.io'

  def self.badge_image(subject, status, color, format='svg')
    resp = get("/badge/#{encode(subject)}-#{encode(status)}-#{color}.#{format}")

    raise HTTParty::ResponseError.new(resp) unless resp.code == 200
    resp.body
  end

  private
  def self.encode(input)
    result = input.dup
    REPLACEMENTS.each do |needle, repl|
      result.gsub! needle, repl
    end
    result
  end
end
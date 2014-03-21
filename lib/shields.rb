require 'httparty'

class Shields
  include HTTParty

  base_uri 'img.shields.io'

  def self.badge_image(subject, status, color, format='svg')
    get("/badge/#{subject}-#{status}-#{color}.#{format}").body
  end
end
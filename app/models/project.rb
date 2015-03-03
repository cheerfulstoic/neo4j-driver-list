require 'active_model'
class Project
  include Neo4j::ActiveNode

  property :link_on_neo4j_com
  property :github
  property :driver_site
  property :mailing_list
  property :last_comit
  property :notes
  property :contacted
  property :e_mail
  property :authors
  property :driver
  property :language

  PROJECT_REPO_CSV_URI = 'https://docs.google.com/a/neotechnology.com/spreadsheets/d/1HWOGc3yBbHq4paLrN4oTOa7IJZjxM5DmrX4pS3MKllk/export?format=csv&id=1HWOGc3yBbHq4paLrN4oTOa7IJZjxM5DmrX4pS3MKllk&gid=0'

  def self.source_data
    require 'csv'
    @source_data ||= CSV.parse(UrlCache.get_url_body(PROJECT_REPO_CSV_URI, expires_in: 2.days))
  end

  def self.header
    source_data.first
  end

  def self.normalized_header
    @normalized_header ||= header.map {|h| h.downcase.gsub(/[^a-z0-9]/i, ' ').strip.squeeze.gsub(' ', '_') }
  end

  def userorg
    github_breakdown && github_breakdown[0]
  end

  def repo
    github_breakdown && github_breakdown[1]
  end

  def github_breakdown
    if github
      match = github.match(/^([^\/]+)\/([^\/]+)\/?$/)
      match && match[1,2]
    end
  end

  def github_repo_commit_activity_stats
    if userorg && repo
      JSON.parse(UrlCache.get_url_body("https://api.github.com/repos/#{userorg}/#{repo}/stats/commit_activity?access_token=#{ENV['GITHUB_TOKEN']}")).sort_by do |row|
        row['week']
      end
    else
      []
    end
  end

  def github_repo_data
    if userorg && repo
      JSON.parse(UrlCache.get_url_body("https://api.github.com/repos/#{userorg}/#{repo}?access_token=#{ENV['GITHUB_TOKEN']}"))
    else
      {}
    end
  end


  def weekly_commit_counts_since(time)
    counts = github_repo_commit_activity_stats.select do |row|
      Time.at(row['week']) > time
    end.sort_by do |row|
      row['week']
    end.map do |row|
      row['days'].sum
    end

    expected_weeks = ((Time.now - time) / 1.week).to_i

    (([0] * expected_weeks) + counts)[-expected_weeks..-1]
  end

#  normalized_header.each do |name|
#    attr_accessor name
#  end

#  def self.all
#    source_data[1..-1].map do |row|
#      self.new(Hash[*normalized_header.zip(row).flatten])
#    end
#  end
end

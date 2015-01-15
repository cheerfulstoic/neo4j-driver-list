require 'csv'
require 'open-uri'
require 'json'
require 'active_support'

CACHE = ActiveSupport::Cache::FileStore.new('cache')
def get_url_body(url)
  CACHE.fetch(url) do
    URI.parse(url).open.read
  end
end


csv_url = 'https://docs.google.com/a/neotechnology.com/spreadsheets/d/1HWOGc3yBbHq4paLrN4oTOa7IJZjxM5DmrX4pS3MKllk/export?format=csv&id=1HWOGc3yBbHq4paLrN4oTOa7IJZjxM5DmrX4pS3MKllk&gid=0'
csv_uri = URI.parse(csv_url)

data = CSV.parse(csv_uri.open.read)
header = data.shift
github_index = header.index('Github')

CSV.open('output.csv', 'w') do |csv|
  csv << header + ['Created', 'Pushed', 'Updated']

  data.each do |row|
    github_url = row[github_index]
    puts "Processing #{github_url}"

    if github_url
      match = github_url.match(/^([^\/]+)\/([^\/]+)\/?$/)
      if match
        userorg, repo = match[1, 2]
        repo_data = JSON.parse(get_url_body("https://api.github.com/repos/#{userorg}/#{repo}?access_token=#{ENV['GITHUB_TOKEN']}"))

        csv << row + [repo_data['created_at'], repo_data['pushed_at'], repo_data['updated_at']]
      else
        csv << row
      end
    else
      csv << row
    end
  end
end


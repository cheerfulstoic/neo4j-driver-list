class UrlCache
  CACHE = if ENV['REDISCLOUD_URL']
            ActiveSupport::Cache::RedisStore.new(ENV['REDISCLOUD_URL'])
          else
            CACHE = ActiveSupport::Cache::FileStore.new('cache')
          end

  def self.get_url_body(url, options = {expires_in: 1.month})
    require 'open-uri'
    CACHE.fetch(url, options) do
      URI.parse(url).open.read
    end
  end
end

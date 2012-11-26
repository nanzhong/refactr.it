REDIS = case Rails.env
when "production"
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Redis.new(:host => '127.0.0.1', :port => 6379)
end

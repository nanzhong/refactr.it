case Rails.env
when "production"
  ENV['ELASTICSEARCH_URL'] = ENV['BONSAI_URL']
else
  ENV['ELASTICSEARCH_URL'] = "http://0.0.0.0:9200"
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, 'd31c3e7336ddbecb2268', '87e7caaefc3fdca1fc89a0e60ace4b23b6fd429c', scope: 'user'
end

json.array!(@sites) do |site|
  json.extract! site, :id, :name, :default_ssl, :mode, :status, :start_time, :end_time
  json.url site_url(site, format: :json)
end

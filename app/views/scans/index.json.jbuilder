json.array!(@scans) do |scan|
  json.extract! scan, :id, :url, :content, :last_visited, :site_id
  json.url scan_url(scan, format: :json)
end

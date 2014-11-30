json.array!(@rules) do |rule|
  json.extract! rule, :id, :site_id, :regex, :positive, :order
  json.url rule_url(rule, format: :json)
end

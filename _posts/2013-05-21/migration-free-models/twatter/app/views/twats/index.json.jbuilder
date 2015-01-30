json.array!(@twats) do |twat|
  json.extract! twat, :author, :status
  json.url twat_url(twat, format: :json)
end
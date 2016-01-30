json.array!(@channels) do |channel|
  json.extract! channel, :id, :name, :total_cent
  json.url channel_url(channel, format: :json)
end

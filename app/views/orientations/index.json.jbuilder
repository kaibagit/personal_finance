json.array!(@orientations) do |orientation|
  json.extract! orientation, :id, :name
  json.url orientation_url(orientation, format: :json)
end

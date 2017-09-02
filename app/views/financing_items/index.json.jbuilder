json.array!(@financing_items) do |financing_item|
  json.extract! financing_item, :id, :financing_id, :money_cent, :paid_at, :interested_at
  json.url financing_item_url(financing_item, format: :json)
end

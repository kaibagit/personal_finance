json.array!(@expenses) do |expense|
  json.extract! expense, :id, :channel_id, :way, :cent, :happened_at
  json.url expense_url(expense, format: :json)
end

json.array!(@financings) do |financing|
  json.extract! financing, :id, :channel_id, :name, :exp_rate, :money_cent, :paid_at, :status, :exp_antedated, :act_antedated, :act_rate, :exp_earning, :act_earning
  json.url financing_url(financing, format: :json)
end

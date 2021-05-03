json.array!(@apr_stages) do |apr_stage|
  json.extract! apr_stage, :id, :begin_date, :end_date, :begin_money, :end_money, :apr, :financing_id
  json.url apr_stage_url(apr_stage, format: :json)
end

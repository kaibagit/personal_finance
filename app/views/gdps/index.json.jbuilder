json.array!(@gdps) do |gdp|
  json.extract! gdp, :id, :month, :m2, :m2_yoy_growth, :m2_chain_growth, :m1, :m1_yoy_growth, :m0, :m0_yoy_growth, :m0_chain_growth
  json.url gdp_url(gdp, format: :json)
end

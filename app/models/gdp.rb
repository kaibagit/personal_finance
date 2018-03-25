class Gdp
  include Mongoid::Document
  field :month, type: String
  field :m2, type: String
  field :m2_yoy_growth, type: String
  field :m2_chain_growth, type: String
  field :m1, type: String
  field :m1_yoy_growth, type: String
  field :m0, type: String
  field :m0_yoy_growth, type: String
  field :m0_chain_growth, type: String
end

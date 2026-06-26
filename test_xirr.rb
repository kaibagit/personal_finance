require "date"

# 场景：2021-06-26 投10000元，2023-06-26 投10000元，2026-06-26 收回24339元
cash_flows = [
  { amount: -1000000.0, date: Date.parse("2021-06-26") },
  { amount: -1000000.0, date: Date.parse("2023-06-26") },
  { amount:  2433900.0, date: Date.parse("2026-06-26") },
]

def compute_xirr(cash_flows, guess: 0.1, max_iter: 100, tolerance: 1e-7)
  return 0.0 if cash_flows.empty?
  rate = guess
  t0 = cash_flows.first[:date]
  max_iter.times do
    pv = 0.0
    d_pv = 0.0
    cash_flows.each do |cf|
      t = (cf[:date] - t0).to_f / 365.0
      discount = (1.0 + rate) ** t
      pv += cf[:amount] / discount
      d_pv += -t * cf[:amount] / (discount * (1.0 + rate))
    end
    break if pv.abs < tolerance
    new_rate = rate - pv / d_pv
    break if (new_rate - rate).abs < tolerance
    rate = new_rate
  end
  rate
end

r = compute_xirr(cash_flows)
puts "XIRR = #{(r * 100).round(2)}%"

# 验证NPV
t0 = cash_flows.first[:date]
npv = cash_flows.sum { |cf| cf[:amount] / ((1 + r) ** ((cf[:date] - t0).to_f / 365.0)) }
puts "NPV = #{npv}"

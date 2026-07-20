# TWR 验证脚本：测试时间加权收益率是否不受赎回时机影响
# 场景：初始投资 1000，一年盈利 100（市值变 1100），赎回 1000 本金，
#       剩下 100 盈利再持有一年赚 10（市值变 110），到期结算。
# 真实年化应为 10%，且不受赎回时机影响。

require 'date'

# 模拟 compute_twr_from_valuations
def compute_twr_from_valuations(events)
  return 0.0 if events.size < 2
  total_days = (events.last[:date] - events.first[:date]).to_i
  return 0.0 if total_days <= 0
  prod = 1.0
  events.each_cons(2) do |a, b|
    days = (b[:date] - a[:date]).to_i
    next if days <= 0
    r = (b[:mv] - a[:mv] - b[:net_flow]) / a[:mv]
    return -1.0 if (1 + r) <= 0
    prod *= (1 + r)
    puts "  子期间: #{a[:date]} -> #{b[:date]} (#{days}天), mv: #{a[:mv]}->#{b[:mv]}, net_flow: #{b[:net_flow]}, r=#{format('%.4f%%', r*100)}"
  end
  (prod ** (365.0 / total_days)) - 1.0
end

start_date = Date.new(2020, 1, 1)

puts "=== 场景1: 第365天赎回（一年后赎回本金） ==="
events1 = [
  { date: start_date,              mv: 1000.0, net_flow: 0.0 },     # 初始投入 1000，市值 1000
  { date: start_date + 365,        mv: 100.0,  net_flow: -1000.0 }, # 赎回 1000 本金，市值剩 100（盈利）
  { date: start_date + 365 + 365,  mv: 110.0,  net_flow: 0.0 },     # 到期结算，市值 110
]
result1 = compute_twr_from_valuations(events1)
puts "  年化: #{format('%.2f%%', result1*100)}"
puts "  预期: 约 10.00%"
puts

puts "=== 场景2: 第180天赎回（半年后赎回本金） ==="
events2 = [
  { date: start_date,              mv: 1000.0, net_flow: 0.0 },
  { date: start_date + 180,        mv: 100.0,  net_flow: -1000.0 }, # 提早赎回
  { date: start_date + 365 + 365,  mv: 110.0,  net_flow: 0.0 },
]
result2 = compute_twr_from_valuations(events2)
puts "  年化: #{format('%.2f%%', result2*100)}"
puts "  预期: 约 10.00%"
puts

puts "=== 场景3: 第30天赎回（极早赎回） ==="
events3 = [
  { date: start_date,              mv: 1000.0, net_flow: 0.0 },
  { date: start_date + 30,         mv: 100.0,  net_flow: -1000.0 },
  { date: start_date + 365 + 365,  mv: 110.0,  net_flow: 0.0 },
]
result3 = compute_twr_from_valuations(events3)
puts "  年化: #{format('%.2f%%', result3*100)}"
puts "  预期: 约 10.00%"
puts

puts "=== 场景4: 无赎回，仅追加投资 ==="
events4 = [
  { date: start_date,              mv: 1000.0, net_flow: 0.0 },
  { date: start_date + 180,        mv: 2100.0, net_flow: 1000.0 }, # 追加 1000，市值变 2100
  { date: start_date + 365 + 365,  mv: 2310.0, net_flow: 0.0 },    # 到期结算（10% 年化）
]
result4 = compute_twr_from_valuations(events4)
puts "  年化: #{format('%.2f%%', result4*100)}"
puts "  预期: 约 10.00%"
puts

puts "=== 场景5: 亏光（边缘情况） ==="
events5 = [
  { date: start_date,              mv: 1000.0, net_flow: 0.0 },
  { date: start_date + 365,        mv: 0.0,    net_flow: 0.0 },  # 本金归零
]
result5 = compute_twr_from_valuations(events5)
puts "  年化: #{format('%.2f%%', result5*100)}"
puts "  预期: -100.00%（亏光返回 -1.0）"
puts

puts "=== 验证结论 ==="
tolerance = 0.001
results = [result1, result2, result3, result4]
all_close = results.all? { |r| (r - 0.10).abs < tolerance }
if all_close && result5 == -1.0
  puts "✓ 全部通过！TWR 不受赎回时机影响，年化始终约为 10%。"
else
  puts "✗ 存在偏差："
  puts "  场景1: #{format('%.4f', result1)}"
  puts "  场景2: #{format('%.4f', result2)}"
  puts "  场景3: #{format('%.4f', result3)}"
  puts "  场景4: #{format('%.4f', result4)}"
  puts "  场景5: #{format('%.4f', result5)}"
end

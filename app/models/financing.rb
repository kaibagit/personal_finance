class Financing < ActiveRecord::Base
	belongs_to :channel
	belongs_to :orientation
	has_many :items,:class_name=> 'FinancingItem'
	has_many :apr_stages,:class_name=> 'AprStage'
	enum status: {started:'started',finished:'finished'}
	enum horizon_unit: {day:'day',month:'month',year:'year'}
	enum risk: {lower_risk:'lower_risk',medium_risk:'medium_risk',high_risk:'high_risk'}
	enum liquidity_type:{current:'current',fixed:'fixed'}
	enum valuation_method: {legacy:'legacy',twr:'twr'}
	enum time_to_liquidity: {unknown:'unknown',realtime:'realtime',t_plus_1:'t_plus_1',within_week:'within_week'}
	default_scope{order('paid_at DESC')}
	#before_save :compute

	# 即将过期的投资
	def self.about_to_expire
		about_to_expire_time = Time.now + 1.month
		Financing.where("status=? and exp_antedated<=?",'started',about_to_expire_time).reorder("exp_antedated")
	end

	#一个月内到期
	def self.expires_in_one_month
		about_to_expire_time = Time.now + 1.month
		financings = Financing.where("status=? and exp_antedated<=?",'started',about_to_expire_time).reorder("exp_antedated")
		financings+self.current_financings
	end

	#三个月内到期
	def self.expires_in_three_month
		about_to_expire_time = Time.now + 3.month
		financings = Financing.where("status=? and exp_antedated<=?",'started',about_to_expire_time).reorder("exp_antedated")
		financings+self.current_financings
	end

	#半年内到期
	def self.expires_in_half_year
		about_to_expire_time = Time.now + 6.month
		financings = Financing.where("status=? and exp_antedated<=?",'started',about_to_expire_time).reorder("exp_antedated")
		financings+self.current_financings
	end

	#一年内到期
	def self.expires_in_one_year
		about_to_expire_time = Time.now + 1.year
		financings = Financing.where("status=? and exp_antedated<=?",'started',about_to_expire_time).reorder("exp_antedated")
		financings+self.current_financings
	end

	#2年内到期
	def self.expires_in_more_than_two_year
		about_to_expire_time = Time.now + 2.year
		financings = Financing.where("status=? and exp_antedated<=?",'started',about_to_expire_time).reorder("exp_antedated")
		financings+self.current_financings
	end

	# 活期投资
	def self.current_financings
		Financing.where("status=? and liquidity_type=?",'started','current').all
	end

	def self.one_month_fixed_financings
		financings = Set.new
		financings.merge(Financing.where("status=? and liquidity_type=? and horizon_unit=? and horizon=?",'started','fixed','month',1).reorder(nil).all)
		financings.merge(Financing.where("status=? and liquidity_type=? and horizon_unit=? and horizon<=?",'started','fixed','day',31).reorder(nil).all)
		financings
	end

	def self.three_month_fixed_financings
		financings = Set.new
		financings.merge(Financing.where("status=? and liquidity_type=? and horizon_unit=? and horizon>? and horizon<=?",'started','fixed','month',1,3).reorder(nil).all)
		financings.merge(Financing.where("status=? and liquidity_type=? and horizon_unit=? and horizon>? and horizon<=?",'started','fixed','day',31,92).reorder(nil).all)
		financings
	end

	def self.half_year_fixed_financings
		Financing.where("status=? and liquidity_type=? and horizon_unit=? and horizon>? and horizon<=?",'started','fixed','month',3,6).all
	end

	def self.one_year_fixed_financings
		financings = Set.new
		financings.merge(Financing.where("status=? and liquidity_type=? and horizon_unit=? and horizon>?",'started','fixed','month',6).reorder(nil).all)
		financings.merge(Financing.where("status=? and liquidity_type=? and horizon_unit=? and horizon=?",'started','fixed','year',1).all)
		financings
	end

	def self.more_than_one_year_fixed_financings
		Financing.where("status=? and liquidity_type=? and horizon_unit=? and horizon>?",'started','fixed','year',1).all
	end

	# 已开始的指定方向投资
	def self.find_started_by_orientation_id(orientation_id)
		Financing.where("status=? and orientation_id=?",'started',orientation_id).all
	end

	def self.liquidity_debug
		financings = Set.new
		Financing.where(:status => 'started').all.each{ |x|
			financings.add x
		}
		puts "size:#{financings.size}"
		puts "-size:#{Financing.current_financings.size}"
		Financing.current_financings.each{ |x|
			financings.delete x
		}
		puts "size:#{financings.size}"
		puts "-size:#{Financing.one_month_fixed_financings.size}"
		Financing.one_month_fixed_financings.each{ |x|
			financings.delete x
		}
		puts "size:#{financings.size}"
		puts "-size:#{Financing.three_month_fixed_financings.size}"
		Financing.three_month_fixed_financings.each{ |x|
			financings.delete x
		}
		puts "size:#{financings.size}"
		puts "-size:#{Financing.half_year_fixed_financings.size}"
		Financing.half_year_fixed_financings.each{ |x|
			financings.delete x
		}
		puts "size:#{financings.size}"
		puts "-size:#{Financing.one_year_fixed_financings.size}"
		Financing.one_year_fixed_financings.each{ |x|
			financings.delete x
		}
		puts "size:#{financings.size}"
		puts "-size:#{Financing.more_than_one_year_fixed_financings.size}"
		Financing.more_than_one_year_fixed_financings.each{ |x|
			financings.delete x
		}
		puts "size:#{financings.size}"
		puts '================'
		financings.each{|x|
			puts x.id
		}
	end

	#追加投资
	def add_to(money_cent)
		puts items.size
		if items.empty?
			item = default_item
			item.save
		end
		self.money_cent+=money_cent
		save
	end

	def default_item
		item = FinancingItem.new
		item.financing = self
		item.money_cent = self.money_cent
		item.paid_at = paid_at
		item.interested_at = interested_at
		item.created_at = created_at
		item.updated_at = updated_at
		item.money_flow = 'balance'
		item.market_value_cent = 0 if twr?
		return item
	end

	def compute
		puts 'compute'
		self.status='started'
		if fixed?
			#计算期望到期时间
			if day?
				self.exp_antedated=(interested_at.advance(days:self.horizon))
			elsif month?
				self.exp_antedated=(interested_at.advance(months:self.horizon))
			elsif year?
				self.exp_antedated=(interested_at.advance(years:self.horizon))
			else
				raise 'unknown horizon_unit'
			end

			#计算期望到期收益
			if exp_earning.blank?
				if day?
					self.exp_earning=money_cent*exp_rate*horizon/365
				elsif month?
					self.exp_earning=money_cent*exp_rate*horizon/12
				elsif year?
					self.exp_earning=money_cent*exp_rate*horizon
				else
					raise 'unknown horizon_unit'
				end
			end

			# 投资完成
			if finished?
				total_days = (act_antedated-interested_at).to_i+1
				# 利率 = (利息/本金)/(计息天数/365) = 利息*365/本金*计息天数
				self.act_rate=Float(act_earning*365)/(money_cent*total_days)
				channel.earning act_earning
			end
		else	#活期
			if finished?
				total_days = (act_antedated-interested_at).to_i+1
				if act_earning.blank?
					self.act_rate = exp_rate
					# 收益 = 本金*(计息天数/365)*利率
					self.act_earning = money_cent*total_days/365*exp_rate
				else
					# 利率 = (利息/本金)/(计息天数/365) = 利息*365/（本金*计息天数）
					self.act_rate=Float(act_earning*365)/(money_cent*total_days)
				end
				channel.earning self.act_earning
			end
		end

	end

	#开始投资
	def to_start
		self.status='started'
		if fixed?
			#计算期望到期时间
			if day?
				self.exp_antedated=(interested_at.advance(days:self.horizon))
			elsif month?
				self.exp_antedated=(interested_at.advance(months:self.horizon))
			elsif year?
				self.exp_antedated=(interested_at.advance(years:self.horizon))
			else
				raise 'unknown horizon_unit'
			end

			#计算期望到期收益
			if exp_earning.blank?
				if day?
					self.exp_earning=money_cent*exp_rate*horizon/365
				elsif month?
					self.exp_earning=money_cent*exp_rate*horizon/12
				elsif year?
					self.exp_earning=money_cent*exp_rate*horizon
				else
					raise 'unknown horizon_unit'
				end
			end
		end

		# 创建初始投资流水
		Financing.transaction do
			save!
			if items.empty?
				item = default_item
				item.save!
			end
		end
	end

	#完成投资
	def to_finish(attributes)
		Financing.transaction do
			return false unless estimate_apr(attributes)	# 校验失败则事务自动回滚
			save!
			#全量刷新阶段年化记录（含最终结算段）
			AprStage.refresh_apr_stages(self)
		end
	end

	# 估算年化
	def estimate_apr(attributes)
		assign_attributes(attributes)
		self.status='finished'

		if twr?
			# Financing 级别统一用资金加权（XIRR）反映真实回报
			unless act_earning.present?
				errors.add(:act_earning, '请填写最终金额以计算收益')
				return false
			end
			settle_amount = money_cent + act_earning
			cash_flows = build_cash_flows(settle_amount)
			xirr = Financing.compute_xirr(cash_flows)
			self.act_rate = (xirr && xirr.finite?) ? xirr.real : nil
		elsif has_initial_item?
			# 有初始流水记录：使用 XIRR 算法
			unless act_earning.present?
				errors.add(:act_earning, '请填写最终金额以计算收益')
				return false
			end
			settle_amount = money_cent + (act_earning || 0)
			cash_flows = build_cash_flows(settle_amount)
			xirr = Financing.compute_xirr(cash_flows)
			self.act_rate = (xirr && xirr.finite?) ? xirr.real : nil
		else
			# 无初始流水记录（历史数据）：使用旧加权天数公式
			# 加权天数
			if items.empty?
				weighting_days = (act_antedated - interested_at).to_i + 1
			else
				sum = 0
				items.each do |item|
					if item.money_cent > 0  # 投资
						invest_days = (act_antedated - item.interested_at).to_i + 1
						sum = sum + (invest_days * item.money_cent)
					else  # 赎回
						compensate_days = (act_antedated - item.paid_at.to_date).to_i
						sum = sum + (compensate_days * item.money_cent)
					end
				end
				weighting_days = sum / money_cent
			end

			if fixed?
				self.act_rate = Float(act_earning * 365) / (money_cent * weighting_days)
			else  # 活期
				if act_earning.blank?
					self.act_rate = exp_rate
					self.act_earning = money_cent * weighting_days / 365 * exp_rate
				else
					self.act_rate = Float(act_earning * 365) / (money_cent * weighting_days)
				end
			end
		end

		channel.earning self.act_earning
	end

	# 判断是否有初始投资流水记录（paid_at 匹配 Financing 的 paid_at）
	def has_initial_item?
		items.any? { |i| i.paid_at.present? && i.paid_at.to_s == paid_at.to_s }
	end

	# 构建现金流列表（XIRR 用）
	def build_cash_flows(settle_amount)
		flows = []

		# 初始投资
		initial = items.find { |i| i.paid_at.present? && i.paid_at.to_s == paid_at.to_s }
		flows << { amount: -(initial ? initial.money_cent : money_cent).to_f, date: interested_at.to_date }

		# 后续追加/赎回
		items.each do |item|
			next if initial && item.id == initial.id
			if item.money_cent > 0
				flows << { amount: -item.money_cent.to_f, date: item.interested_at.to_date }
			else
				flows << { amount: -item.money_cent.to_f, date: item.paid_at.to_date }
			end
		end

		# 最终回款
		flows << { amount: settle_amount.to_f, date: act_antedated.to_date }

		flows.sort_by { |f| f[:date] }
	end

	# XIRR 计算：牛顿迭代法求解内部收益率
	def self.compute_xirr(cash_flows, guess: 0.1, max_iter: 100, tolerance: 1e-7)
		return 0.0 if cash_flows.empty?

		# 现金流必须同时有正有负，否则 IRR 无意义
		amounts = cash_flows.map { |cf| cf[:amount] }
		return nil if amounts.all? { |a| a >= 0 } || amounts.all? { |a| a <= 0 }

		rate = guess
		t0 = cash_flows.first[:date]

		max_iter.times do
			# 本金已全损（rate <= -1），货币时间价值无意义，直接停止
			return nil if 1.0 + rate <= 0

			pv = 0.0
			d_pv = 0.0

			cash_flows.each do |cf|
				t = (cf[:date] - t0).to_f / 365.0  # 以年为单位的时间差
				discount = (1.0 + rate) ** t
				pv += cf[:amount] / discount
				# 导数：-t * amount / (1+rate)^(t+1)
				d_pv += -t * cf[:amount] / (discount * (1.0 + rate))
			end

			return rate if pv.abs < tolerance

			# 导数过小，避免步长爆炸导致发散
			return nil if d_pv.abs < 1e-12

			new_rate = rate - pv / d_pv
			# 钳制在合理年化区间，防止发散到天文数字
			new_rate = 1000.0  if new_rate > 1000.0    # 上限 100000%
			new_rate = -0.9999 if new_rate < -0.9999   # 下限（全损边界）

			# 步长已极小，近似收敛
			if (new_rate - rate).abs < tolerance
				rate = new_rate
				break
			end

			rate = new_rate
		end

		# 收敛失败/结果非有限，不返回非法值
		return nil unless rate.finite?
		rate.real
	end

	# 计算"资金进出前"的年化收益率（统一使用资金加权 XIRR）
	# new_item 为即将新增的流水（未持久化），其 market_value_cent 即进出前市值
	def pre_addition_apr(new_item)
		pre_mv = new_item.market_value_cent
		return nil unless pre_mv.present?

		old_items = items.to_a
		return nil if old_items.empty?

		flows = []
		initial = old_items.find { |i| i.paid_at.present? && i.paid_at.to_s == paid_at.to_s }
		flows << { amount: -(initial ? initial.money_cent : money_cent).to_f, date: interested_at.to_date }
		old_items.each do |it|
			next if initial && it.id == initial.id
			if it.money_cent > 0
				flows << { amount: -it.money_cent.to_f, date: it.interested_at.to_date }
			else
				flows << { amount: -it.money_cent.to_f, date: it.paid_at.to_date }
			end
		end
		d = new_item.money_cent > 0 ? new_item.interested_at.to_date : new_item.paid_at.to_date
		flows << { amount: pre_mv.to_f, date: d }
		flows.sort_by! { |f| f[:date] }
		Financing.compute_xirr(flows)
	end

	# TWR（时间加权收益率）：基于市值事件计算年化收益率
	# events: 按日期升序 [{date:, mv:, net_flow:}]
	#   mv = 该笔资金进出后的账户总市值
	#   net_flow = 该笔净流入（追加为正，赎回为负）
	def self.compute_twr_from_valuations(events)
		return 0.0 if events.size < 2

		total_days = (events.last[:date] - events.first[:date]).to_i
		return 0.0 if total_days <= 0

		prod = 1.0
		events.each_cons(2) do |a, b|
			days = (b[:date] - a[:date]).to_i
			next if days <= 0

			# 子期间收益率 = (期末市值 - 期初市值 - 期间净流入) / 期初市值
			r = (b[:mv] - a[:mv] - b[:net_flow]) / a[:mv]

			# 某段亏光（本金归零），TWR 无意义
			return -1.0 if (1 + r) <= 0

			prod *= (1 + r)
		end

		(prod ** (365.0 / total_days)) - 1.0
	end

	# 构建 TWR 市值事件列表
	def twr_events
		events = []

		# 期初：首笔资金进入后的市值（market_value_cent 是进出前值，需加上金额得到进出后值）
		first_item = items.min_by(&:paid_at)
		if first_item&.market_value_cent.present?
			initial_mv = first_item.market_value_cent + (first_item.money_cent || 0)
		else
			initial_mv = money_cent || 0
		end
		events << { date: interested_at.to_date, mv: initial_mv.to_f, net_flow: 0.0 }

		# 各笔资金进出
		items.each do |it|
			next unless it.market_value_cent.present?
			d = it.money_cent > 0 ? it.interested_at.to_date : it.paid_at.to_date
			events << {
				date: d,
				mv: (it.market_value_cent + it.money_cent).to_f,
				net_flow: it.money_cent.to_f
			}
		end

		# 期末：结算市值（仅完成投资时追加，进行中不生成最终结算事件）
		if finished? && act_antedated.present?
			final_mv = (money_cent || 0) + (act_earning || 0)
			events << { date: act_antedated.to_date, mv: final_mv.to_f, net_flow: 0.0 }
		end

		events.sort_by { |e| e[:date] }
	end

	def money_yuan
		if money_cent.blank?
			return nil
		end
		BigDecimal(money_cent)/100
	end

	def money_yuan=(value)
		self.money_cent=Float(value)*100
	end

	def exp_earning_yuan
		if exp_earning.blank?
			return nil
		end
		BigDecimal(exp_earning)/100
	end

	def exp_earning_yuan=(value)
		unless value.blank?
			self.exp_earning=Float(value)*100
		end
	end


	# 实际收益（元）
	def act_earning_yuan
		if act_earning.blank?
			return nil
		end
		BigDecimal(act_earning)/100
	end
	def act_earning_yuan=(value)
		unless value.blank?
			self.act_earning=Float(value)*100
		end
	end

	# 结算金额（元）
	def settle_money_yuan
		return nil
	end
	def settle_money_yuan=(value)
		unless value.blank?
			self.act_earning_yuan=Float(value)-self.money_yuan
		end
	end

	def exp_rate_percent
		if exp_rate.blank?
			return nil
		end
		(exp_rate*100).round(2)
	end

	def exp_rate_percent=(value)
		self.exp_rate=Float(value)/100
	end

	def act_rate_percent
		if act_rate.blank?
			return nil
		end
		(act_rate*100).round(2)
	end

	# 变现速度中文标签
	def time_to_liquidity_text
		{unknown: '未知', realtime: '实时', t_plus_1: 'T+1', within_week: '一周内'}[time_to_liquidity&.to_sym]
	end
end

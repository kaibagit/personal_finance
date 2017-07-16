class Financing < ActiveRecord::Base
	belongs_to :channel
	enum status: {started:'started',finished:'finished'}
	enum horizon_unit: {day:'day',month:'month',year:'year'}
	enum risk: {lower_risk:'lower_risk',medium_risk:'medium_risk',high_risk:'high_risk'}
	enum liquidity_type:{current:'current',fixed:'fixed'}
	default_scope{order('paid_at DESC')}
	before_save :compute

	# 即将过期的投资
	def self.about_to_expire
		about_to_expire_time = Time.now + 1.month
		Financing.where("status=? and exp_antedated<=?",'started',about_to_expire_time).reorder("exp_antedated")
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
			unless act_antedated.blank? and act_earning.blank?
				total_days = (act_antedated-interested_at).to_i+1
				# 利率 = (利息/本金)/(计息天数/365) = 利息*365/本金*计息天数
				self.act_rate=Float(act_earning*365)/(money_cent*total_days)
				self.status='finished'
				channel.earning act_earning
			end
		else	#活期
			unless id.blank?
				total_days = (act_antedated-interested_at).to_i+1
				if act_earning.blank?
					self.act_rate = exp_rate
					# 收益 = 本金*(计息天数/365)*利率
					self.act_earning = money_cent*total_days/365*exp_rate
				else
					# 利率 = (利息/本金)/(计息天数/365) = 利息*365/本金*计息天数
					self.act_rate=Float(act_earning*365)/(money_cent*total_days)
				end

				self.status='finished'
				channel.earning self.act_earning
			end
		end



	end

	def finish(attributes)
		update(attributes)
	end

	def money_yuan
		if money_cent.blank?
			return nil
		end
		BigDecimal.new(money_cent)/100
	end

	def money_yuan=(value)
		self.money_cent=Float(value)*100
	end

	def exp_earning_yuan
		if exp_earning.blank?
			return nil
		end
		BigDecimal.new(exp_earning)/100
	end

	def exp_earning_yuan=(value)
		unless value.blank?
			self.exp_earning=Float(value)*100
		end
	end

	def act_earning_yuan
		if act_earning.blank?
			return nil
		end
		BigDecimal.new(act_earning)/100
	end

	def act_earning_yuan=(value)
		unless value.blank?
			self.act_earning=Float(value)*100
		end
	end

	def exp_rate_percent
		if exp_rate.blank?
			return nil
		end
		exp_rate*100
	end

	def exp_rate_percent=(value)
		self.exp_rate=Float(value)/100
	end

	def act_rate_percent
		if act_rate.blank?
			return nil
		end
		act_rate*100
	end
end

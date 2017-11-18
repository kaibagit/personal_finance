class Financing < ActiveRecord::Base
	belongs_to :channel
	belongs_to :orientation
	has_many :items,:class_name=> 'FinancingItem'
	enum status: {started:'started',finished:'finished'}
	enum horizon_unit: {day:'day',month:'month',year:'year'}
	enum risk: {lower_risk:'lower_risk',medium_risk:'medium_risk',high_risk:'high_risk'}
	enum liquidity_type:{current:'current',fixed:'fixed'}
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
					# 利率 = (利息/本金)/(计息天数/365) = 利息*365/本金*计息天数
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
		save
	end

	#完成投资
	def to_finish(attributes)
		update_attributes(attributes)
		self.status='finished'

		#加权天数
		weighting_days = 0
		if self.items.empty?
			weighting_days = (act_antedated-interested_at).to_i+1
		else
			sum = 0;
			self.items.each{|item|
				if item.money_cent > 0	#投资
					logger.debug("投资A=#{act_antedated}")
					logger.debug("投资A=#{item.interested_at}")
					invest_days = (act_antedated-item.interested_at).to_i+1
					logger.debug("投资=#{invest_days}")
					sum = sum + ( invest_days*item.money_cent )
				else	#赎回
					logger.info(item.paid_at.class.instance_methods)
					compensate_days = (act_antedated-item.paid_at.to_date).to_i		#赎回金额多计算了，需要补偿
					logger.debug("赎回=#{compensate_days}")
					sum = sum + ( compensate_days*item.money_cent )
				end
			}
			weighting_days = sum/self.money_cent
		end
		logger.debug("天数=#{weighting_days}")
		# 计算利率
		if fixed?
			# 利率 = (利息/本金)/(计息天数/365) = 利息*365/本金*加权天数
			self.act_rate=Float(act_earning*365)/(money_cent*weighting_days)
		else #活期
			if act_earning.blank?
				self.act_rate = exp_rate
				# 收益 = 本金*(计息天数/365)*利率
				self.act_earning = money_cent*weighting_days/365*exp_rate
			else
				# 利率 = (利息/本金)/(计息天数/365) = 利息*365/本金*加权天数
				self.act_rate=Float(act_earning*365)/(money_cent*weighting_days)
			end
		end
		channel.earning self.act_earning
		save
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

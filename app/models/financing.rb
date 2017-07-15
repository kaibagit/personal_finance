class Financing < ActiveRecord::Base
	belongs_to :channel
	enum status: {started:'started',finished:'finished'}
	enum horizon_unit: {day:'day',month:'month',year:'year'}
	enum risk: {lower_risk:'lower_risk',medium_risk:'medium_risk',high_risk:'high_risk'}
	enum liquidity_type:{current:'current',fixed:'fixed'}
	default_scope{order('paid_at DESC')}
	before_save :compute

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

class Financing < ActiveRecord::Base
	belongs_to :channel
	enum status: {started:'started',finished:'finished'}
	enum horizon_unit: {day:'day',month:'month',year:'year'}
	default_scope{order('paid_at DESC')}
	before_save :compute

	def compute
		puts 'compute'
		self.status='started'

		if day?
			self.exp_antedated=(interested_at.advance(days:self.horizon))
		elsif month?
			self.exp_antedated=(interested_at.advance(months:self.horizon))
		elsif year?
			self.exp_antedated=(interested_at.advance(years:self.horizon))
		else
			raise 'unknown horizon_unit'
		end

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

		unless act_antedated.blank? and act_earning.blank?
			total_days = (act_antedated-interested_at).to_i+1
			# 利率 = (利息/本金)/(计息天数/365) = 利息*365/本金*计息天数
			self.act_rate=Float(act_earning*365)/(money_cent*total_days)
			self.status='finished'
			channel.change_cent act_earning
			channel.save
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

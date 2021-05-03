class AprStage < ActiveRecord::Base
  belongs_to :financing

  def AprStage.save_last_stage_when_financing_finish(financing)
    last_apr_stage = financing.apr_stages.last
    apr_stage = AprStage.new
    apr_stage.financing=financing
    unless last_apr_stage.blank?
      apr_stage.begin_date=last_apr_stage.end_date
      apr_stage.begin_money=last_apr_stage.end_money
    else
      apr_stage.begin_date=financing.paid_at.to_date
      apr_stage.begin_money=financing.money_cent
    end
    apr_stage.end_money=financing.money_cent+financing.act_earning
    apr_stage.end_date=financing.act_antedated
    apr_stage.compute_and_save
  end

  # 计算年化并保存
  def compute_and_save
    #加权天数
		days = end_date-begin_date
    # 利率 = (利息/本金)/(天数/365) = 利息*365/（本金*天数）
    self.apr=(end_money-begin_money)*365/(begin_money*days)
    save
  end

  def begin_money_yuan
		if begin_money.blank?
			return nil
		end
		BigDecimal.new(begin_money)/100
	end
	def begin_money_yuan=(value)
		self.begin_money=Float(value)*100
	end

  def end_money_yuan
		if end_money.blank?
			return nil
		end
		BigDecimal.new(end_money)/100
	end
	def end_money_yuan=(value)
		self.end_money=Float(value)*100
	end

  def apr_percent
		if apr.blank?
			return nil
		end
		apr*100
	end
end

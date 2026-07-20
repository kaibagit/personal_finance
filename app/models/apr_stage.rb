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

  # 计算年化并保存（使用 XIRR 算法）
  def compute_and_save
    cash_flows = build_stage_cash_flows
    self.apr = Financing.compute_xirr(cash_flows)
    save
  end

  # 构建阶段内现金流
  def build_stage_cash_flows
    flows = []
    flows << { amount: -begin_money.to_f, date: begin_date }

    # 阶段内的追加/赎回流水
    self.financing.items.each do |item|
      item_date = item.money_cent > 0 ? item.interested_at.to_date : item.paid_at.to_date
      if item_date > begin_date && item_date <= end_date
        flows << { amount: -item.money_cent.to_f, date: item_date }
      end
    end

    flows << { amount: end_money.to_f, date: end_date }
    flows.sort_by { |f| f[:date] }
  end

  def begin_money_yuan
		if begin_money.blank?
			return nil
		end
		BigDecimal(begin_money)/100
	end
	def begin_money_yuan=(value)
		self.begin_money=Float(value)*100
	end

  def end_money_yuan
		if end_money.blank?
			return nil
		end
		BigDecimal(end_money)/100
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

class Channel < ActiveRecord::Base
  has_many :expenses
	has_many :financings
	default_scope{order('id')}

	def total_yuan
		BigDecimal.new(total_cent)/100
	end

	def change_cent(cent)
		self.total_cent=total_cent+cent
    save
	end

  # 收益
  def earning(cent)
    self.earnings=earnings+cent
    change_cent(cent)
  end

  def earnings_yuan
    if earnings.blank?
      return nil
    end
    BigDecimal.new(earnings)/100
  end

  # 低风险金额
  def lower_risk_money
    Financing.where(:channel => self, :status => 'started', :risk => 'lower_risk').sum(:money_cent)
  end

  # 中等风险金额
  def medium_risk_money
    Financing.where(:channel => self, :status => 'started', :risk => 'medium_risk').sum(:money_cent)
  end

  # 高风险金额
  def high_risk_money
    Financing.where(:channel => self, :status => 'started', :risk => 'high_risk').sum(:money_cent)
  end

  def other_money
    total_cent-lower_risk_money-medium_risk_money-high_risk_money
  end

end

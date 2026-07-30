class FinancingItem < ActiveRecord::Base
  belongs_to :financing
  default_scope{order('paid_at DESC')}

  after_save :refresh_apr
  after_destroy :refresh_apr

  attr_accessor :money_flow
  validates :money_flow, presence: { message: '资金往来不能为空' }
  validates :market_value_cent, presence: { message: 'TWR模式下资金进出需填写资金进出前的市值' },
    if: :require_market_value_for_twr?

  def add(money_flow)
    Financing.transaction do
      financing = Financing.find(financing_id)
      self.pre_apr = financing.pre_addition_apr(self)
      financing.add_to(self.money_cent)
      result = save

      if 'outside' == money_flow
        channel = financing.channel
        if self.money_cent > 0
          expense = Expense.new
          expense.channel = channel
          expense.way = 'incoming'
          expense.cent = self.money_cent
          expense.happened_at = self.created_at
          expense.save
        else
          expense = Expense.new
          expense.channel = channel
          expense.way = 'outgoings'
          expense.cent = self.money_cent
          expense.happened_at = self.created_at
          expense.save
        end
      end

      return result
    end
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

  def market_value_yuan
    BigDecimal(market_value_cent)/100 if market_value_cent.present?
  end

  def market_value_yuan=(value)
    self.market_value_cent = Float(value)*100 if value.present?
  end

  private

  def refresh_apr
    AprStage.refresh_apr_stages(financing) if financing.present?
  end

  def require_market_value_for_twr?
    Financing.find_by(id: financing_id)&.twr?
  end
end

class FinancingItem < ActiveRecord::Base
  belongs_to :financing
  default_scope{order('paid_at DESC')}

  def add(money_flow)
    Financing.transaction do
      financing = Financing.find(financing_id)
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
		BigDecimal.new(money_cent)/100
	end

	def money_yuan=(value)
		self.money_cent=Float(value)*100
	end
end

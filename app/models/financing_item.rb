class FinancingItem < ActiveRecord::Base
  belongs_to :financing

  def add
    financing = Financing.find(financing_id)
    financing.add_to(self.money_cent)
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
end

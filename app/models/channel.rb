class Channel < ActiveRecord::Base
  has_many :expenses
	has_many :financings
	default_scope{order('id')}

	def total_yuan
		BigDecimal.new(total_cent)/100
	end

	def change_cent(cent)
		self.total_cent=total_cent+cent
	end
end

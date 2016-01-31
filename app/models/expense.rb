class Expense < ActiveRecord::Base
  belongs_to :channel
	enum way: {incoming:'incoming', outgoings:'outgoings'}
	default_scope{order('happened_at DESC')}
	after_save :change_channel

	def yuan
		BigDecimal.new(cent)/100
	end

	def change_channel
		channel.change_cent(cent)
		channel.save
	end
end

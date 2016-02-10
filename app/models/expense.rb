class Expense < ActiveRecord::Base
  belongs_to :channel
	enum way: {incoming:'incoming', outgoings:'outgoings'}
	default_scope{order('happened_at DESC')}
	after_save :change_channel

	def yuan
    if cent.blank?; return nil; end
		BigDecimal.new(cent)/100
	end

  def yuan=(value)
    value = Float(value)
    if outgoings?; value=value*(-1); end
    self.cent=value*100
  end

	def change_channel
		channel.change_cent(cent)
	end
end

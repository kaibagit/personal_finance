class AprStage < ActiveRecord::Base
  belongs_to :financing

  # 全量刷新阶段年化记录（投资进行中或完成投资时均可调用）
  def AprStage.refresh_apr_stages(financing)
    financing.apr_stages.destroy_all

    if financing.twr?
      # TWR 模式：按每笔流水拆成多段，每段独立计算时间加权收益率
      # 进行中时只生成已有市值快照之间的封闭段；完成投资后会追加最后一段（含结算）
      events = financing.twr_events
      return if events.size < 2

      events.each_cons(2) do |a, b|
        days = (b[:date] - a[:date]).to_i
        next if days <= 0

        stage = AprStage.new
        stage.financing  = financing
        stage.begin_date = a[:date]
        stage.begin_money = a[:mv].round
        stage.end_date   = b[:date]
        stage.end_money  = b[:mv].round
        stage.net_flow   = b[:net_flow].round
        stage.compute_twr_and_save
      end
    else
      # 无市值快照：整段资金加权（XIRR）兜底，仅完成投资时可计算
      return unless financing.finished?

      stage = AprStage.new
      stage.financing  = financing
      stage.begin_date = financing.paid_at.to_date
      stage.begin_money = financing.money_cent
      stage.end_date   = financing.act_antedated
      stage.end_money  = financing.money_cent + financing.act_earning
      stage.compute_and_save
    end
  end

  # 单段时间加权年化（TWR）
  def compute_twr_and_save
    bm, em, nf = begin_money.to_f, end_money.to_f, (net_flow || 0).to_f
    days = (end_date - begin_date).to_i
    if bm <= 0 || days <= 0
      self.apr = nil
      return save
    end
    r = (em - bm - nf) / bm
    self.apr = (1 + r) <= 0 ? -1.0 : ((1 + r) ** (365.0 / days) - 1.0)
    save
  end

  # 整段资金加权年化（XIRR，非 TWR 模式兜底）
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

  def net_flow_yuan
    return nil if net_flow.blank?
    BigDecimal(net_flow) / 100
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

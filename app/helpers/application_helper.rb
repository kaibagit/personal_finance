module ApplicationHelper

  def cent_to_yuan(cent)
    if cent.blank?; return ''; end
    cent/100.0
  end

  def div_to_percent(v1,v2)
    if v2.blank?; return ''; end
    result_float = Float(v1)/v2
    format_to_percent(result_float)
  end

  def format_to_percent(value)
    if value.blank?; return ''; end
    if value.class != Float; value=Float(value); end
    ( (value*100).round(2)).to_s+' %'
  end

  # 金额格式化：统一精确到小数点后2位
  def format_yuan(value)
    return '' if value.blank?
    number_with_precision(value, precision: 2)
  end

end

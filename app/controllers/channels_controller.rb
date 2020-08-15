class ChannelsController < ApplicationController
  before_action :set_channel, only: [:show, :edit, :update, :destroy]

  # GET /channels
  # GET /channels.json
  def index
    @channels = Channel.where('effective is null or effective =true')
    @total_cent = @total_lower_risk = @total_medium_risk = @total_high_risk = 0
    @channels.each do |c|
      @total_cent+=c.total_cent
      @total_lower_risk+=c.lower_risk_money
      @total_medium_risk+=c.medium_risk_money
      @total_high_risk+=c.high_risk_money
    end
    @other = @total_cent-@total_lower_risk-@total_medium_risk-@total_high_risk
    @total_yuan = @total_cent/100.0
    @about_to_expire_financings = Financing.about_to_expire

    # 流动性
    # 一个月内到期
    expires_in_one_month = Financing.expires_in_one_month
    expires_in_one_month_cent = sum_cent(expires_in_one_month)
    expires_in_one_month_rage = sum_earnings(expires_in_one_month)
    @expires_in_one_month = {
      :cent => expires_in_one_month_cent ,
      :size => expires_in_one_month.size ,
      :average_rate => expires_in_one_month_rage/expires_in_one_month_cent
    }
    # 三个月内到期
    expires_in_three_month = Financing.expires_in_three_month
    expires_in_three_month_cent = sum_cent(expires_in_three_month)
    expires_in_three_month_rate = sum_earnings(expires_in_three_month)
    @expires_in_three_month = {
      :cent => expires_in_three_month_cent ,
      :size => expires_in_three_month.size ,
      :average_rate => expires_in_three_month_rate/expires_in_three_month_cent
    }
    # 半年内到期
    expires_in_half_year = Financing.expires_in_half_year
    expires_in_half_year_cent = sum_cent(expires_in_half_year)
    expires_in_half_year_rate = sum_earnings(expires_in_half_year)
    @expires_in_half_year = {
      :cent => expires_in_half_year_cent ,
      :size => expires_in_half_year.size ,
      :average_rate => expires_in_half_year_rate/expires_in_half_year_cent
    }
    # 一年内到期
    expires_in_one_year = Financing.expires_in_one_year
    expires_in_one_year_cent = sum_cent(expires_in_one_year)
    expires_in_one_year_rate = sum_earnings(expires_in_one_year)
    @expires_in_one_year = {
      :cent => expires_in_one_year_cent ,
      :size => expires_in_one_year.size ,
      :average_rate => expires_in_one_year_rate/expires_in_one_year_cent
    }
    # 2年内到期
    expires_in_more_than_two_year = Financing.expires_in_more_than_two_year
    expires_in_more_than_two_year_cent = sum_cent(expires_in_more_than_two_year)
    expires_in_more_than_two_year_rate = sum_earnings(expires_in_more_than_two_year)
    @expires_in_more_than_two_year = {
      :cent => expires_in_more_than_two_year_cent ,
      :size => expires_in_more_than_two_year.size ,
      :average_rate => expires_in_more_than_two_year_rate/expires_in_more_than_two_year_cent
    }

    # 流动性偏好
    # 活期期限
    current_financings = Financing.current_financings
    current_financings_cent = sum_cent(current_financings)
    current_financings_rate = sum_earnings(current_financings)
    @current_financings = {
      :cent => current_financings_cent ,
      :size => current_financings.size ,
      :average_rate => current_financings_rate/current_financings_cent
    }
    # 一个月内期限
    one_month_fixed_financings = Financing.one_month_fixed_financings
    one_month_fixed_financings_cent = sum_cent(one_month_fixed_financings)
    one_month_fixed_financings_rate = sum_earnings(one_month_fixed_financings)
    @one_month_fixed_financings = {
      :cent => one_month_fixed_financings_cent ,
      :size => one_month_fixed_financings.size ,
      :average_rate => one_month_fixed_financings_rate/one_month_fixed_financings_cent
    }
    # 三个月内期限
    three_month_fixed_financings = Financing.three_month_fixed_financings
    three_month_fixed_financings_cent = sum_cent(three_month_fixed_financings)
    three_month_fixed_financings_rate = sum_earnings(three_month_fixed_financings)
    @three_month_fixed_financings = {
      :cent => three_month_fixed_financings_cent ,
      :size => three_month_fixed_financings.size ,
      :average_rate => three_month_fixed_financings_rate/three_month_fixed_financings_cent
    }
    #半年内期限
    half_year_fixed_financings = Financing.half_year_fixed_financings
    half_year_fixed_financings_cent = sum_cent(half_year_fixed_financings)
    half_year_fixed_financings_rate = sum_earnings(half_year_fixed_financings)
    @half_year_fixed_financings = {
      :cent => half_year_fixed_financings_cent ,
      :size => half_year_fixed_financings.size ,
      :average_rate => half_year_fixed_financings_rate/half_year_fixed_financings_cent
    }
    # 一年内期限
    one_year_fixed_financings = Financing.one_year_fixed_financings
    one_year_fixed_financings_cent = sum_cent(one_year_fixed_financings)
    one_year_fixed_financings_rate = sum_earnings(one_year_fixed_financings)
    @one_year_fixed_financings = {
      :cent => one_year_fixed_financings_cent ,
      :size => one_year_fixed_financings.size ,
      :average_rate => one_year_fixed_financings_rate/one_year_fixed_financings_cent
    }
    # 一年以上期限
    more_than_one_year_fixed_financings = Financing.more_than_one_year_fixed_financings
    more_than_one_year_fixed_financings_cent = sum_cent(more_than_one_year_fixed_financings)
    more_than_one_year_fixed_financings_rate = sum_earnings(more_than_one_year_fixed_financings)
    @more_than_one_year_fixed_financings = {
      :cent => more_than_one_year_fixed_financings_cent ,
      :size => more_than_one_year_fixed_financings.size ,
      :average_rate => more_than_one_year_fixed_financings_rate/more_than_one_year_fixed_financings_cent
    }

    @other_liquidity_cent = @total_cent-current_financings_cent-one_month_fixed_financings_cent-three_month_fixed_financings_cent-
      half_year_fixed_financings_cent-one_year_fixed_financings_cent-more_than_one_year_fixed_financings_cent

    @average_rate = (current_financings_rate+one_month_fixed_financings_rate+three_month_fixed_financings_rate+half_year_fixed_financings_rate+one_year_fixed_financings_rate+more_than_one_year_fixed_financings_rate)/@total_cent
    #Financing.liquidity_debug

    @orientation_stat = Hash.new
    Orientation.all.each{ |o|
      total_money = Financing.find_started_by_orientation_id(o.id).map(&:money_cent).reduce(0, :+)
      @orientation_stat[o] = total_money
      #orientation_stat.store(o.name,total_money)
    }
  end

  # 总计金额
  def sum_cent(financings)
    financings.inject(0) { |sum, e| sum += e.money_cent }
  end

  # 总结收益
  def sum_earnings(financings)
    financings.inject(0.0) { |sum, e| sum += e.money_cent*e.exp_rate }
  end

  # GET /channels/1
  # GET /channels/1.json
  def show
  end

  # GET /channels/new
  def new
    @channel = Channel.new
  end

  # GET /channels/1/edit
  def edit
  end

  # POST /channels
  # POST /channels.json
  def create
    @channel = Channel.new(channel_params)
    if @channel.total_cent.nil?; @channel.total_cent=0; end
    if @channel.earnings.nil?; @channel.earnings=0; end

    respond_to do |format|
      if @channel.save
        format.html { redirect_to action: "index"}
        format.json { render :show, status: :created, location: @channel }
      else
        format.html { render :new }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /channels/1
  # PATCH/PUT /channels/1.json
  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to action: "index"}
        format.json { render :show, status: :ok, location: @channel }
      else
        format.html { render :edit }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel.effective = false
    @channel.save
    respond_to do |format|
      format.html { redirect_to channels_url, notice: 'Channel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      @channel = Channel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def channel_params
      params.require(:channel).permit(:name, :total_cent)
    end
end

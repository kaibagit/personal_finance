class FinancingsController < ApplicationController
  before_action :set_financing, only: [:show, :edit, :update, :destroy, :finish_view, :finish]

  # GET /financings
  # GET /financings.json
  def index
    @status = params['status']
		@channel = Channel.find(params['channel_id'])
    # sql = 'channel_id = ?'
    # conditions = [sql,@channel.id]
    # unless @status.blank?
    #   sql << ' and status = ?'
    #   conditions << @status
    # end
    # @financings = Financing.where(conditions)
    @financings = Financing.where(:channel => @channel)
    @lower_risk_money = @medium_risk_money = @high_risk_money = 0
    @financings.each do |f|
      if f.started?
        if f.lower_risk?
          @lower_risk_money+=f.money_cent
        elsif f.medium_risk?
          @medium_risk_money+=f.money_cent
        elsif f.high_risk?
          @high_risk_money+=f.money_cent
        end
      end
    end
  end

  def current
    @financings = Financing.current_financings
    @total_cent = 0
    @lower_risk_money = @medium_risk_money = @high_risk_money = 0
    @financings.each do |f|
      if f.started?
        @total_cent+=f.money_yuan
        if f.lower_risk?
          @lower_risk_money+=f.money_cent
        elsif f.medium_risk?
          @medium_risk_money+=f.money_cent
        elsif f.high_risk?
          @high_risk_money+=f.money_cent
        end
      end
    end
  end

  # GET /financings/1
  # GET /financings/1.json
  def show
  end

  # GET /financings/new
  def new
		@channel = Channel.find(params['channel_id'])
    @financing = Financing.new
		@financing.channel = @channel
  end

  # GET /financings/1/edit
  def edit
  end

  # POST /financings
  # POST /financings.json
  def create
    @financing = Financing.new(financing_params)

    respond_to do |format|
      if @financing.to_start
        #format.html { redirect_to @financing, notice: 'Financing was successfully created.' }
				format.html { redirect_to action: "index",channel_id: @financing.channel_id }
        format.json { render :show, status: :created, location: @financing }
      else
        format.html { render :new }
        format.json { render json: @financing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /financings/1
  # PATCH/PUT /financings/1.json
  def update
    respond_to do |format|
      if @financing.update(financing_params)
        #format.html { redirect_to @financing, notice: 'Financing was successfully updated.' }
				format.html { redirect_to action: "index",channel_id: @financing.channel_id }
        format.json { render :show, status: :ok, location: @financing }
      else
        format.html { render :edit }
        format.json { render json: @financing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /financings/1
  # DELETE /financings/1.json
  def destroy
    @financing.destroy
    respond_to do |format|
      format.html { redirect_to action: "index",channel_id: @financing.channel_id }
      format.json { head :no_content }
    end
  end

  def finish_view
    if @financing.act_earning.blank?
      @financing.act_earning=@financing.exp_earning
    end
  end

  # 完成
  def finish
    puts @financing.attributes
		respond_to do |format|
      if @financing.to_finish(financing_params)
				format.html { redirect_to action: "index",channel_id: @financing.channel_id }
        format.json { render :show, status: :ok, location: @financing }
      else
        format.html { render :edit }
        format.json { render json: @financing.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_financing
      @financing = Financing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def financing_params
      params.require(:financing).permit(
        :channel_id, :name, :exp_rate, :money_cent, :paid_at, :status, :exp_antedated, :act_antedated, :act_rate,
         :exp_earning, :exp_earning_yuan, :act_earning, :money_yuan, :exp_rate_percent, :horizon, :horizon_unit, :interested_at ,:act_earning_yuan, :risk,
         :liquidity_type, :orientation_id)
    end
end

class AprStagesController < ApplicationController
  before_action :set_apr_stage, only: [:show, :edit, :update, :destroy]

  # GET /apr_stages
  # GET /apr_stages.json
  def index
    @financing = Financing.find(params['financing_id'])
    @apr_stages = @financing.apr_stages
  end

  # GET /apr_stages/1
  # GET /apr_stages/1.json
  def show
  end

  # GET /apr_stages/new
  def new
    @financing = Financing.find(params['financing_id'])
    last_apr_stage = @financing.apr_stages.last
    @apr_stage = AprStage.new
    @apr_stage.financing=@financing
    unless last_apr_stage.blank?
      @apr_stage.begin_date=last_apr_stage.end_date
      @apr_stage.begin_money=last_apr_stage.end_money
    else
      @apr_stage.begin_date=@financing.paid_at.to_date
      @apr_stage.begin_money=@financing.money_cent
    end
  end

  # GET /apr_stages/1/edit
  def edit
  end

  # POST /apr_stages
  # POST /apr_stages.json
  def create
    # @financing_item = FinancingItem.new(financing_item_params)
    #
    # respond_to do |format|
    #   if @financing_item.add(params[:money_flow])
    #     format.html { redirect_to action: "index",financing_id: @financing_item.financing.id }
    #     format.json { render :show, status: :created, location: @financing_item }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @financing_item.errors, status: :unprocessable_entity }
    #   end
    # end

    @apr_stage = AprStage.new(apr_stage_params)

    respond_to do |format|
      if @apr_stage.compute_and_save
        format.html { redirect_to action: "index",financing_id: @apr_stage.financing_id }
        format.json { render :show, status: :created, location: @apr_stage }
      else
        format.html { render :new }
        format.json { render json: @apr_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /apr_stages/1
  # PATCH/PUT /apr_stages/1.json
  def update
    respond_to do |format|
      if @apr_stage.update(apr_stage_params)
        format.html { redirect_to @apr_stage, notice: 'Apr stage was successfully updated.' }
        format.json { render :show, status: :ok, location: @apr_stage }
      else
        format.html { render :edit }
        format.json { render json: @apr_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apr_stages/1
  # DELETE /apr_stages/1.json
  def destroy
    @apr_stage.destroy
    respond_to do |format|
      format.html { redirect_to apr_stages_url, notice: 'Apr stage was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_apr_stage
      @apr_stage = AprStage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def apr_stage_params
      params.require(:apr_stage).permit(:begin_date, :end_date, :begin_money, :end_money, :apr, :financing_id, :end_money_yuan)
    end
end

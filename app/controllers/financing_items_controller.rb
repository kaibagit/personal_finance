class FinancingItemsController < ApplicationController
  before_action :set_financing_item, only: [:show, :edit, :update, :destroy]

  # GET /financing_items
  # GET /financing_items.json
  def index
    @financing = Financing.find(params['financing_id'])
    @financing_items = @financing.items
    if @financing_items.empty?
      @financing_items.push @financing.default_item
    end
  end

  # GET /financing_items/1
  # GET /financing_items/1.json
  def show
  end

  # GET /financing_items/new
  def new
    @financing = Financing.find(params['financing_id'])
    @financing_item = FinancingItem.new
    @financing_item.financing = @financing
  end

  # GET /financing_items/1/edit
  def edit
  end

  # POST /financing_items
  # POST /financing_items.json
  def create
    @financing_item = FinancingItem.new(financing_item_params)

    respond_to do |format|
      if @financing_item.add
        format.html { redirect_to action: "index",financing_id: @financing_item.financing.id }
        format.json { render :show, status: :created, location: @financing_item }
      else
        format.html { render :new }
        format.json { render json: @financing_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /financing_items/1
  # PATCH/PUT /financing_items/1.json
  def update
    respond_to do |format|
      if @financing_item.update(financing_item_params)
        format.html { redirect_to @financing_item, notice: 'Financing item was successfully updated.' }
        format.json { render :show, status: :ok, location: @financing_item }
      else
        format.html { render :edit }
        format.json { render json: @financing_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /financing_items/1
  # DELETE /financing_items/1.json
  def destroy
    @financing_item.destroy
    respond_to do |format|
      format.html { redirect_to financing_items_url, notice: 'Financing item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_financing_item
      @financing_item = FinancingItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def financing_item_params
      params.require(:financing_item).permit(:financing_id, :money_cent, :paid_at, :interested_at, :money_yuan)
    end
end

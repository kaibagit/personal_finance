class GdpsController < ApplicationController
  before_action :set_gdp, only: [:show, :edit, :update, :destroy]

  # GET /gdps
  # GET /gdps.json
  def index
    @gdps = Gdp.all
    @reverse_gdps = @gdps.reverse
  end

  # GET /gdps/1
  # GET /gdps/1.json
  def show
  end

  # GET /gdps/new
  def new
    @gdp = Gdp.new
  end

  # GET /gdps/1/edit
  def edit
  end

  # POST /gdps
  # POST /gdps.json
  def create
    @gdp = Gdp.new(gdp_params)

    respond_to do |format|
      if @gdp.save
        format.html { redirect_to @gdp, notice: 'Gdp was successfully created.' }
        format.json { render :show, status: :created, location: @gdp }
      else
        format.html { render :new }
        format.json { render json: @gdp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gdps/1
  # PATCH/PUT /gdps/1.json
  def update
    respond_to do |format|
      if @gdp.update(gdp_params)
        format.html { redirect_to @gdp, notice: 'Gdp was successfully updated.' }
        format.json { render :show, status: :ok, location: @gdp }
      else
        format.html { render :edit }
        format.json { render json: @gdp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gdps/1
  # DELETE /gdps/1.json
  def destroy
    @gdp.destroy
    respond_to do |format|
      format.html { redirect_to gdps_url, notice: 'Gdp was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gdp
      @gdp = Gdp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gdp_params
      params.require(:gdp).permit(:month, :m2, :m2_yoy_growth, :m2_chain_growth, :m1, :m1_yoy_growth, :m0, :m0_yoy_growth, :m0_chain_growth)
    end
end

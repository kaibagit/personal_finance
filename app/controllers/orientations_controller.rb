class OrientationsController < ApplicationController
  before_action :set_orientation, only: [:show, :edit, :update, :destroy]

  # GET /orientations
  # GET /orientations.json
  def index
    @orientations = Orientation.all
  end

  # GET /orientations/1
  # GET /orientations/1.json
  def show
  end

  # GET /orientations/new
  def new
    @orientation = Orientation.new
  end

  # GET /orientations/1/edit
  def edit
  end

  # POST /orientations
  # POST /orientations.json
  def create
    @orientation = Orientation.new(orientation_params)

    respond_to do |format|
      if @orientation.save
        format.html { redirect_to @orientation, notice: 'Orientation was successfully created.' }
        format.json { render :show, status: :created, location: @orientation }
      else
        format.html { render :new }
        format.json { render json: @orientation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orientations/1
  # PATCH/PUT /orientations/1.json
  def update
    respond_to do |format|
      if @orientation.update(orientation_params)
        format.html { redirect_to @orientation, notice: 'Orientation was successfully updated.' }
        format.json { render :show, status: :ok, location: @orientation }
      else
        format.html { render :edit }
        format.json { render json: @orientation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orientations/1
  # DELETE /orientations/1.json
  def destroy
    @orientation.destroy
    respond_to do |format|
      format.html { redirect_to orientations_url, notice: 'Orientation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orientation
      @orientation = Orientation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def orientation_params
      params.require(:orientation).permit(:name)
    end
end

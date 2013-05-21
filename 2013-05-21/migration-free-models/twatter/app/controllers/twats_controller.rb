class TwatsController < ApplicationController
  before_action :set_twat, only: [:show, :edit, :update, :destroy]

  # GET /twats
  # GET /twats.json
  def index
    @twats = Twat.all
  end

  # GET /twats/1
  # GET /twats/1.json
  def show
  end

  # GET /twats/new
  def new
    @twat = Twat.new
  end

  # GET /twats/1/edit
  def edit
  end

  # POST /twats
  # POST /twats.json
  def create
    @twat = Twat.new(twat_params)

    respond_to do |format|
      if @twat.save
        format.html { redirect_to @twat, notice: 'Twat was successfully created.' }
        format.json { render action: 'show', status: :created, location: @twat }
      else
        format.html { render action: 'new' }
        format.json { render json: @twat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /twats/1
  # PATCH/PUT /twats/1.json
  def update
    respond_to do |format|
      if @twat.update(twat_params)
        format.html { redirect_to @twat, notice: 'Twat was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @twat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twats/1
  # DELETE /twats/1.json
  def destroy
    @twat.destroy
    respond_to do |format|
      format.html { redirect_to twats_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twat
      @twat = Twat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twat_params
      params.require(:twat).permit(:author, :status)
    end
end

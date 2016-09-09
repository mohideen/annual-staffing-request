class RoleCutoffsController < ApplicationController
  before_action :set_role_cutoff, only: [:show, :edit, :update, :destroy]

  # GET /role_cutoffs
  # GET /role_cutoffs.json
  def index
    @role_cutoffs = RoleCutoff.all
  end

  # GET /role_cutoffs/1
  # GET /role_cutoffs/1.json
  def show
  end

  # GET /role_cutoffs/new
  def new
    @role_cutoff = RoleCutoff.new
  end

  # GET /role_cutoffs/1/edit
  def edit
  end

  # POST /role_cutoffs
  # POST /role_cutoffs.json
  def create
    @role_cutoff = RoleCutoff.new(role_cutoff_params)

    respond_to do |format|
      if @role_cutoff.save
        format.html { redirect_to @role_cutoff, notice: 'Role cutoff was successfully created.' }
        format.json { render :show, status: :created, location: @role_cutoff }
      else
        format.html { render :new }
        format.json { render json: @role_cutoff.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /role_cutoffs/1
  # PATCH/PUT /role_cutoffs/1.json
  def update
    respond_to do |format|
      if @role_cutoff.update(role_cutoff_params)
        format.html { redirect_to @role_cutoff, notice: 'Role cutoff was successfully updated.' }
        format.json { render :show, status: :ok, location: @role_cutoff }
      else
        format.html { render :edit }
        format.json { render json: @role_cutoff.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /role_cutoffs/1
  # DELETE /role_cutoffs/1.json
  def destroy
    @role_cutoff.destroy
    respond_to do |format|
      format.html { redirect_to role_cutoffs_url, notice: 'Role cutoff was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role_cutoff
      @role_cutoff = RoleCutoff.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_cutoff_params
      params.require(:role_cutoff).permit(:role_type_id, :cutoff_date)
    end
end

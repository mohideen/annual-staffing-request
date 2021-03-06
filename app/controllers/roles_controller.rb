class RolesController < ApplicationController
  # rubocop:disable Metrics/MethodLength
  before_action :set_role, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized

  # GET /roles
  # GET /roles.json
  def index
    authorize Role
    @q = Role.ransack(params[:q])
    @q.sorts = 'user' if @q.sorts.empty?

    @roles = @q.result.includes(:user, :role_type, :division, :department, :unit).page(params[:page])
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
    authorize Role
  end

  # GET /roles/new
  def new
    authorize Role
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit
    authorize Role
  end

  # POST /roles
  # POST /roles.json
  def create
    authorize Role
    @role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        format.html { redirect_to @role, notice: "Role #{@role.description} was successfully created." }
        format.json { render :show, status: :created, location: @role }
      else
        format.html { render :new }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roles/1
  # PATCH/PUT /roles/1.json
  def update
    authorize Role
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to @role, notice: "Role #{@role.description} was successfully updated." }
        format.json { render :show, status: :ok, location: @role }
      else
        format.html { render :edit }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    authorize Role
    respond_to do |format|
      if delete
        format.html { redirect_to roles_url, notice: "Role #{@role.description} was successfully destroyed." }
        format.json { head :no_content }
      else
        format.html { redirect_to roles_url, flash: { error: @error_msg } }
        format.json { render json: [error], status: :unprocessable_entity }
      end
    end
  end

  private

    # Returns true if the current role was deleted. If the role
    # cannot be deleted due an ActiveRecord::DeleteRestrictionError, populates
    # @error_msg and returns false.
    def delete
      @role.destroy
      return true
    rescue ActiveRecord::DeleteRestrictionError
      @error_msg = 'Role cannot be removed as it is used by other records.'
      return false
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_role
      @role = Role.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def role_params
      params.require(:role).permit(:user_id, :role_type_id, :division_id, :department_id, :unit_id)
    end
end

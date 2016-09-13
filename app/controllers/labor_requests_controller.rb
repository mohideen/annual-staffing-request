class LaborRequestsController < ApplicationController
  include PersonnelRequestController
  before_action :set_labor_request, only: [:show, :edit, :update, :destroy]
  after_action :verify_policy_scoped, only: :index

  # GET /labor_requests
  # GET /labor_requests.json
  def index
    @q = LaborRequest.ransack(params[:q])
    @q.sorts = 'position_description' if @q.sorts.empty?
    results = @q.result.includes(%i( division employee_type request_type unit ))
    @labor_requests = policy_scope(results).page(params[:page])
  end

  # GET /labor_requests/1
  # GET /labor_requests/1.json
  def show
    authorize @labor_request
  end

  # GET /labor_requests/new
  def new
    authorize LaborRequest
    @labor_request = LaborRequest.new
  end

  # GET /labor_requests/1/edit
  def edit
    authorize @labor_request
  end

  # POST /labor_requests
  # POST /labor_requests.json
  # rubocop:disable Metrics/MethodLength
  def create
    @labor_request = LaborRequest.new(labor_request_params)
    authorize @labor_request

    respond_to do |format|
      if @labor_request.save
        format.html { redirect_to @labor_request, notice: 'Labor request was successfully created.' }
        format.json { render :show, status: :created, location: @labor_request }
      else
        format.html { render :new }
        format.json { render json: @labor_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /labor_requests/1
  # PATCH/PUT /labor_requests/1.json
  def update
    authorize @labor_request
    respond_to do |format|
      if @labor_request.update(labor_request_params)
        format.html { redirect_to @labor_request, notice: 'Labor request was successfully updated.' }
        format.json { render :show, status: :ok, location: @labor_request }
      else
        format.html { render :edit }
        format.json { render json: @labor_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /labor_requests/1
  # DELETE /labor_requests/1.json
  def destroy
    authorize @labor_request
    @labor_request.destroy
    respond_to do |format|
      format.html { redirect_to labor_requests_url, notice: 'Labor request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_labor_request
      @labor_request = LaborRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def labor_request_params
      params.require(:labor_request).permit(
        :employee_type_id, :position_description, :request_type_id,
        :contractor_name, :number_of_positions, :hourly_rate, :hours_per_week,
        :number_of_weeks, :nonop_funds, :nonop_source, :department_id,
        :unit_id, :justification)
    end
end

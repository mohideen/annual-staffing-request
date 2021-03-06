class ContractorRequestsController < ApplicationController
  # rubocop:disable Metrics/MethodLength
  include PersonnelRequestController
  before_action :set_contractor_request, only: [:show, :edit, :update, :destroy]
  after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  # GET /contractor_requests
  # GET /contractor_requests.json
  def index
    @q = ContractorRequest.ransack(params[:q])

    default_sorts!
    @contractor_requests = scope_records(params)

    respond_to do |format|
      format.html
      format.xlsx { send_xlsx(@contractor_requests, ContractorRequest) }
    end
  end

  # GET /contractor_requests/1
  # GET /contractor_requests/1.json
  def show
    authorize @contractor_request
  end

  # GET /contractor_requests/new
  def new
    authorize ContractorRequest
    @contractor_request = ContractorRequest.new
    assign_selectable_departments_and_units(@contractor_request)
  end

  # GET /contractor_requests/1/edit
  def edit
    authorize @contractor_request
    assign_selectable_departments_and_units(@contractor_request)
  end

  # POST /contractor_requests
  # POST /contractor_requests.json
  def create
    @contractor_request = ContractorRequest.new(contractor_request_params)
    authorize @contractor_request

    respond_to do |format|
      if @contractor_request.save
        format.html do
          redirect_to @contractor_request,
                      notice: "Contractor request for #{@contractor_request.description} was successfully created."
        end
        format.json { render :show, status: :created, location: @contractor_request }
      else
        format.html do
          assign_selectable_departments_and_units(@contractor_request)
          render :new
        end
        format.json { render json: @contractor_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contractor_requests/1
  # PATCH/PUT /contractor_requests/1.json
  def update
    authorize @contractor_request
    respond_to do |format|
      if @contractor_request.update(contractor_request_params)
        format.html do
          redirect_to @contractor_request,
                      notice: "Contractor request for #{@contractor_request.description} was successfully updated."
        end
        format.json { render :show, status: :ok, location: @contractor_request }
      else
        format.html do
          assign_selectable_departments_and_units(@contractor_request)
          render :edit
        end
        format.json { render json: @contractor_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contractor_requests/1
  # DELETE /contractor_requests/1.json
  def destroy
    authorize @contractor_request
    @contractor_request.destroy
    respond_to do |format|
      format.html { redirect_to contractor_requests_url, notice: "Contractor request for #{@contractor_request.description} was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_contractor_request
      @contractor_request = ContractorRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contractor_request_params
      localized_fields = { annual_base_pay: :number, nonop_funds: :number }
      allowed = [:employee_type_id, :position_title, :request_type_id,
                 :contractor_name, :number_of_months, :annual_base_pay,
                 :nonop_funds, :nonop_source, :department_id, :unit_id,
                 :justification] + policy(@contractor_request || ContractorRequest.new).permitted_attributes
      params.require(:contractor_request).permit(allowed).delocalize(localized_fields)
    end
end

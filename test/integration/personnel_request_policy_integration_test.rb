require 'test_helper'

# Integration test for Personnel Request Policy
class PersonnelRequestPolicyIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @dept1 = departments_with_records[0]
    @dept2 = departments_with_records[1]
  end

  def teardown
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def test_verify_labor_request_authorization_in_controller
    no_role_user = User.create(cas_directory_id: 'no_role', name: 'No Role')
    run_as_user(no_role_user) do
      # New
      get new_labor_request_path
      assert_redirected_to root_url
    end
    no_role_user.destroy!

    dept1_request = LaborRequest.where(department: @dept1)[0]
    dept2_request = LaborRequest.where(department: @dept2)[0]
    with_temp_user(departments: [@dept1.code]) do |temp_user|
      run_as_user(temp_user) do
        # Show
        get labor_request_path(dept1_request)
        assert_response :success

        get labor_request_path(dept2_request)
        assert_redirected_to root_url

        # New
        get new_labor_request_path
        assert_response :success

        # Edit
        get edit_labor_request_path(dept1_request)
        assert_response :success

        get edit_labor_request_path(dept2_request)
        assert_redirected_to root_url

        # Create
        post labor_requests_path, labor_request: {
          contractor_name: dept1_request.contractor_name,
          department_id: dept1_request.department_id,
          employee_type_id: dept1_request.employee_type_id,
          hourly_rate: dept1_request.hourly_rate,
          hours_per_week: dept1_request.hours_per_week,
          justification: dept1_request.justification,
          nonop_funds: dept1_request.nonop_funds,
          nonop_source: dept1_request.nonop_source,
          number_of_positions: dept1_request.number_of_positions,
          number_of_weeks: dept1_request.number_of_weeks,
          position_title: dept1_request.position_title,
          request_type_id: dept1_request.request_type_id,
          unit_id: dept1_request.unit_id }
        assert_redirected_to labor_request_path(assigns(:labor_request))

        post labor_requests_path, labor_request: {
          contractor_name: dept2_request.contractor_name,
          department_id: dept2_request.department_id,
          employee_type_id: dept2_request.employee_type_id,
          hourly_rate: dept2_request.hourly_rate,
          hours_per_week: dept2_request.hours_per_week,
          justification: dept2_request.justification,
          nonop_funds: dept2_request.nonop_funds,
          nonop_source: dept2_request.nonop_source,
          number_of_positions: dept2_request.number_of_positions,
          number_of_weeks: dept2_request.number_of_weeks,
          position_title: dept2_request.position_title,
          request_type_id: dept2_request.request_type_id,
          unit_id: dept2_request.unit_id }
        assert_equal path, labor_requests_path
        assert_select '.alert-danger', "Department You are not allowed to make requests to department: #{dept2_request.department.name}"

        # Update
        patch labor_request_path(dept1_request), labor_request: { position_title: 'Foo' }
        assert_redirected_to labor_request_path(dept1_request)

        patch labor_request_path(dept2_request), labor_request: { position_title: 'Foo' }
        assert_redirected_to root_url

        # Destroy
        delete labor_request_path(dept1_request)
        assert_redirected_to labor_requests_url

        delete labor_request_path(dept2_request)
        assert_redirected_to root_url
      end
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def test_verify_contractor_request_authorization_in_controller
    no_role_user = User.create(cas_directory_id: 'no_role', name: 'No Role')
    run_as_user(no_role_user) do
      # New
      get new_contractor_request_path
      assert_redirected_to root_url
    end
    no_role_user.destroy!

    dept1_request = ContractorRequest.where(department: @dept1)[0]
    dept2_request = ContractorRequest.where(department: @dept2)[0]
    with_temp_user(departments: [@dept1.code]) do |temp_user|
      run_as_user(temp_user) do
        # Show
        get contractor_request_path(dept1_request)
        assert_response :success

        get contractor_request_path(dept2_request)
        assert_redirected_to root_url

        # New
        get new_contractor_request_path
        assert_response :success

        # Edit
        get edit_contractor_request_path(dept1_request)
        assert_response :success

        get edit_contractor_request_path(dept2_request)
        assert_redirected_to root_url

        # Create
        post contractor_requests_path, contractor_request: {
          contractor_name: dept1_request.contractor_name,
          department_id: dept1_request.department_id,
          employee_type_id: dept1_request.employee_type_id,
          justification: dept1_request.justification,
          number_of_months: dept1_request.number_of_months,
          annual_base_pay: dept1_request.annual_base_pay,
          nonop_funds: dept1_request.nonop_funds,
          nonop_source: dept1_request.nonop_source,
          position_title: dept1_request.position_title,
          request_type_id: dept1_request.request_type_id,
          unit_id: dept1_request.unit_id }
        assert_redirected_to contractor_request_path(assigns(:contractor_request))

        post contractor_requests_path, contractor_request: {
          contractor_name: dept2_request.contractor_name,
          department_id: dept2_request.department_id,
          employee_type_id: dept2_request.employee_type_id,
          justification: dept2_request.justification,
          number_of_months: dept2_request.number_of_months,
          annual_base_pay: dept2_request.annual_base_pay,
          nonop_funds: dept2_request.nonop_funds,
          nonop_source: dept2_request.nonop_source,
          position_title: dept2_request.position_title,
          request_type_id: dept2_request.request_type_id,
          unit_id: dept2_request.unit_id }
        assert_equal path, contractor_requests_path
        assert_select '.alert-danger', "Department You are not allowed to make requests to department: #{dept2_request.department.name}"

        # Update
        patch contractor_request_path(dept1_request), contractor_request: { position_title: 'Foo' }
        assert_redirected_to contractor_request_path(dept1_request)

        patch contractor_request_path(dept2_request), contractor_request: { position_title: 'Foo' }
        assert_redirected_to root_url

        # Destroy
        delete contractor_request_path(dept1_request)
        assert_redirected_to contractor_requests_url

        delete contractor_request_path(dept2_request)
        assert_redirected_to root_url
      end
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def test_verify_staff_request_authorization_in_controller
    no_role_user = User.create(cas_directory_id: 'no_role', name: 'No Role')
    run_as_user(no_role_user) do
      # New
      get new_staff_request_path
      assert_redirected_to root_url
    end
    no_role_user.destroy!

    dept1_request = StaffRequest.where(department: @dept1)[0]
    dept2_request = StaffRequest.where(department: @dept2)[0]
    with_temp_user(departments: [@dept1.code]) do |temp_user|
      run_as_user(temp_user) do
        # Show
        get staff_request_path(dept1_request)
        assert_response :success

        get staff_request_path(dept2_request)
        assert_redirected_to root_url

        # New
        get new_staff_request_path
        assert_response :success

        # Edit
        get edit_staff_request_path(dept1_request)
        assert_response :success

        get edit_staff_request_path(dept2_request)
        assert_redirected_to root_url

        # Create
        post staff_requests_path, staff_request: {
          department_id: dept1_request.department_id,
          employee_type_id: dept1_request.employee_type_id,
          justification: dept1_request.justification,
          annual_base_pay: dept1_request.annual_base_pay,
          nonop_funds: dept1_request.nonop_funds,
          nonop_source: dept1_request.nonop_source,
          position_title: dept1_request.position_title,
          request_type_id: dept1_request.request_type_id,
          employee_name: dept1_request.employee_name, 
          unit_id: dept1_request.unit_id }

        assert_redirected_to staff_request_path(assigns(:staff_request))

        post staff_requests_path, staff_request: {
          department_id: dept2_request.department_id,
          employee_type_id: dept2_request.employee_type_id,
          justification: dept2_request.justification,
          annual_base_pay: dept2_request.annual_base_pay,
          nonop_funds: dept2_request.nonop_funds,
          nonop_source: dept2_request.nonop_source,
          position_title: dept2_request.position_title,
          request_type_id: dept2_request.request_type_id,
          unit_id: dept2_request.unit_id }
        assert_equal path, staff_requests_path
        assert_select '.alert-danger', "Department You are not allowed to make requests to department: #{dept2_request.department.name}"

        # Update
        patch staff_request_path(dept1_request), staff_request: { position_title: 'Foo' }
        assert_redirected_to staff_request_path(dept1_request)

        patch staff_request_path(dept2_request), staff_request: { position_title: 'Foo' }
        assert_redirected_to root_url

        # Destroy
        delete staff_request_path(dept1_request)
        assert_redirected_to staff_requests_url

        delete staff_request_path(dept2_request)
        assert_redirected_to root_url
      end
    end
  end
end

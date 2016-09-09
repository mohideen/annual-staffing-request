# Policy for Personnel Request actions
class PersonnelRequestPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    show_allowed_by_role?(user, record)
  end

  def create?
    create_allowed_by_role?(user, record)
  end

  def new?
    new_allowed_by_role?(user)
  end

  def update?
    update_allowed_by_role?(user, record)
  end

  def destroy?
    destroy_allowed_by_role?(user, record)
  end

  # Returns an array of Departments in the division
  #
  # division - the Division to return the departments of
  def self.departments_in_division(division)
    Department.where(division_id: division)
  end

  # Returns an array of Departments the user's roles allow access to.
  # This includes departments the user can see because of a Division role,
  # but does NOT include departments from Unit roles (because the user is
  # only allowed to see the entries for that unit, not the whole department.
  def self.allowed_departments(user)
    allowed_departments = []

    division_roles = user.roles(RoleType.find_by_code('division'))
    division_roles.each do |r|
      allowed_departments += departments_in_division(r.division)
    end

    department_roles = user.roles(RoleType.find_by_code('department'))
    department_roles.each do |r|
      allowed_departments << r.department
    end

    allowed_departments.uniq
  end

  # Returns an array of Units the user's roles allow access to
  def self.allowed_units(user)
    allowed_units = []
    unit_roles = user.roles(RoleType.find_by_code('unit'))
    unit_roles.each do |r|
      allowed_units << r.unit
    end
    allowed_units
  end

  # Limits the scope of returned results based on role
  class Scope < Scope
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength,
    def resolve
      if user.admin?
        # Admin always sees everything
        return scope
      end

      # Division scope
      if user.division?
        # Users with Division role can see everything
        return scope
      end

      union_performed = false
      result_scope = scope.none

      # Department scope
      allowed_departments = PersonnelRequestPolicy.allowed_departments(user)
      unless allowed_departments.empty?
        department_results = scope.where(department_id: allowed_departments)
        union_performed, result_scope = union_results(result_scope, department_results)
      end

      # Unit scope
      allowed_units = PersonnelRequestPolicy.allowed_units(user)
      unless allowed_units.empty?
        unit_results = scope.where(unit_id: allowed_units)
        union_performed, result_scope = union_results(result_scope, unit_results)
      end

      if union_performed
        # When a union is performed, we lose the connection to the
        # associated tables. The following joins reconnects the associations
        scope_table_name = scope.table_name
        result_scope = result_scope.joins(
          "LEFT OUTER JOIN departments on departments.id = #{scope_table_name}.department_id")
        result_scope = result_scope.joins(
          "LEFT OUTER JOIN units on units.id = #{scope_table_name}.unit_id")
        result_scope = result_scope.joins(
          "LEFT OUTER JOIN employee_types on employee_types.id = #{scope_table_name}.employee_type_id")
        result_scope = result_scope.joins(
          "LEFT OUTER JOIN request_types on request_types.id = #{scope_table_name}.request_type_id")
      end
      result_scope
    end

    private

      # Performs a union between the given current results and the new results.
      # Returns an array consisting of a boolean indicating whether a union
      # was performed, and the updated results.
      def union_results(current_results, new_results)
        union_performed = false
        new_union = current_results
        if new_results.any?
          if current_results.empty?
            new_union = new_results.reorder(nil)
          else
            new_union = current_results.union(new_results.reorder(nil))
            union_performed = true
          end
        end

        [union_performed, new_union]
      end
  end

  private

    # Returns true if a user is allowed to show the given record, false
    # otherwise.
    def show_allowed_by_role?(user, record)
      return false if user.roles.empty?

      return true if user.admin?

      # Division role can see all entries
      return true if user.division?

      # Department role can see record if in department
      allowed_departments = PersonnelRequestPolicy.allowed_departments(user)
      return true if allowed_departments.include?(record.department)

      # Unit role can see record if in unit
      allowed_units = PersonnelRequestPolicy.allowed_units(user)
      return true if allowed_units.include?(record.unit)

      false
    end

    # Returns true if a user is allowed to create the given record, false
    # otherwise.
    def create_allowed_by_role?(user, record)
      update_allowed_by_role?(user, record)
    end

    # Returns true if a user is allowed to generate new records, false
    # otherwise.
    def new_allowed_by_role?(user)
      return true if user.roles.any?
    end

    # Returns true if a user is allowed to edit the given record, false
    # otherwise.
    def update_allowed_by_role?(user, record)
      return false if user.roles.empty?

      return true if user.admin?

      # Division and Department role can edit record if in department
      allowed_departments = PersonnelRequestPolicy.allowed_departments(user)
      return true if allowed_departments.include?(record.department)

      # Unit role can see record if in unit
      allowed_units = PersonnelRequestPolicy.allowed_units(user)
      return true if allowed_units.include?(record.unit)

      false
    end

    # Returns true if a user is allowed to destroy the given record, false
    # otherwise.
    def destroy_allowed_by_role?(user, record)
      update_allowed_by_role?(user, record)
    end
end
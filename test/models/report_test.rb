require 'test_helper'

# Tests for the "RoleType" model
class ReportTest < ActiveSupport::TestCase
  def setup
    @report = reports(:awesome)
  end

  test 'should be valid' do
    @report = reports(:awesome)
    assert @report.valid?
  end

  test 'name, format, status should be present' do
    %i( name format status ).each do |attr|
      r = @report.dup
      r.attributes = Hash[attr, nil]
      assert_not r.valid?
    end
  end

  test 'role type without associated records can be deleted' do
    r = Report.create(name: 'AwesomeReport', format: 'xlsx', status: 'completed')
    assert_nothing_raised ActiveRecord::DeleteRestrictionError do
      r.destroy
    end
  end

  test "should return it's manager when asked" do
    @report = reports(:awesome)
    assert_equal(@report.manager.to_s, 'Report::Manager')
  end

  test "should return it's policy when asked" do
    @report = reports(:awesome)
    assert_equal(@report.class.policy_class.to_s, 'ReportPolicy')
  end

  test 'should register the reports that are present' do
    class ::CrazyReport; end
    @report = reports(:awesome)
    @report.manager.register_report(CrazyReport)
    assert_includes(@report.manager.reports, ['Crazy Report', 'crazy_report'])
  end

  test 'should return an instance of a report when manager is asked' do
    class ::NotCrazyReport; end
    @report = reports(:awesome)
    @report.manager.register_report(NotCrazyReport)
    not_crazy_report = @report.manager.report_for('not_crazy_report')
    assert_instance_of(NotCrazyReport, not_crazy_report)
  end
end

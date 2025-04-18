require "test_helper"

class Freelancers::JobsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get freelancers_jobs_index_url
    assert_response :success
  end

  test "should get show" do
    get freelancers_jobs_show_url
    assert_response :success
  end
end

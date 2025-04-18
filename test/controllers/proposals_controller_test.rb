require "test_helper"

class ProposalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @proposal = proposals(:one)
  end

  test "should get index" do
    get proposals_url
    assert_response :success
  end

  test "should get new" do
    get new_proposal_url
    assert_response :success
  end

  test "should create proposal" do
    assert_difference("Proposal.count") do
      post proposals_url, params: { proposal: { attachments: @proposal.attachments, cover_letter: @proposal.cover_letter, estimated_time: @proposal.estimated_time, freelancer_id: @proposal.freelancer_id, job_id: @proposal.job_id, offer_amount: @proposal.offer_amount, status: @proposal.status } }
    end

    assert_redirected_to proposal_url(Proposal.last)
  end

  test "should show proposal" do
    get proposal_url(@proposal)
    assert_response :success
  end

  test "should get edit" do
    get edit_proposal_url(@proposal)
    assert_response :success
  end

  test "should update proposal" do
    patch proposal_url(@proposal), params: { proposal: { attachments: @proposal.attachments, cover_letter: @proposal.cover_letter, estimated_time: @proposal.estimated_time, freelancer_id: @proposal.freelancer_id, job_id: @proposal.job_id, offer_amount: @proposal.offer_amount, status: @proposal.status } }
    assert_redirected_to proposal_url(@proposal)
  end

  test "should destroy proposal" do
    assert_difference("Proposal.count", -1) do
      delete proposal_url(@proposal)
    end

    assert_redirected_to proposals_url
  end
end

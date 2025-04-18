require "application_system_test_case"

class ProposalsTest < ApplicationSystemTestCase
  setup do
    @proposal = proposals(:one)
  end

  test "visiting the index" do
    visit proposals_url
    assert_selector "h1", text: "Proposals"
  end

  test "should create proposal" do
    visit proposals_url
    click_on "New proposal"

    fill_in "Attachments", with: @proposal.attachments
    fill_in "Cover letter", with: @proposal.cover_letter
    fill_in "Estimated time", with: @proposal.estimated_time
    fill_in "Freelancer", with: @proposal.freelancer_id
    fill_in "Job", with: @proposal.job_id
    fill_in "Offer amount", with: @proposal.offer_amount
    fill_in "Status", with: @proposal.status
    click_on "Create Proposal"

    assert_text "Proposal was successfully created"
    click_on "Back"
  end

  test "should update Proposal" do
    visit proposal_url(@proposal)
    click_on "Edit this proposal", match: :first

    fill_in "Attachments", with: @proposal.attachments
    fill_in "Cover letter", with: @proposal.cover_letter
    fill_in "Estimated time", with: @proposal.estimated_time
    fill_in "Freelancer", with: @proposal.freelancer_id
    fill_in "Job", with: @proposal.job_id
    fill_in "Offer amount", with: @proposal.offer_amount
    fill_in "Status", with: @proposal.status
    click_on "Update Proposal"

    assert_text "Proposal was successfully updated"
    click_on "Back"
  end

  test "should destroy Proposal" do
    visit proposal_url(@proposal)
    accept_confirm { click_on "Destroy this proposal", match: :first }

    assert_text "Proposal was successfully destroyed"
  end
end

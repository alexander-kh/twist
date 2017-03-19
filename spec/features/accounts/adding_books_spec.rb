require "rails_helper"

feature "Adding books" do
  let(:plan) { Plan.create(name: "Starter", books_allowed: 1) }
  let(:account) { FactoryGirl.create(:account, :subscribed, plan: plan) }

  context "as the account's owner" do
    before do
      login_as(account.owner)
    end

    it "can add a Markdown book" do
      set_subdomain(account.subdomain)
      visit root_url
      click_link "Add Book"
      fill_in "Title", with: "Markdown Book Test"
      fill_in "GitHub Username", with: "radar"
      fill_in "GitHub Repo", with: "markdown_book_test"
      select "Markdown", from: "Format"
      click_button "Add Book"
      expect(page).to have_content("Markdown Book Test has been enqueued for processing.")
    end

    it "can add an AsciiDoc book" do
      set_subdomain(account.subdomain)
      visit root_url
      click_link "Add Book"
      fill_in "Title", with: "Markdown Book Test"
      fill_in "GitHub Username", with: "radar"
      fill_in "GitHub Repo", with: "asciidoc_book_test"
      select "AsciiDoc", from: "Format"
      click_button "Add Book"
      expect(page).to have_content("Markdown Book Test has been enqueued for processing.")
    end
  end
end

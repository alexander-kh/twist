module Accounts
  class BaseController < ApplicationController
    before_action :authorize_user!
    before_action :subscription_required!

    def current_account
      @current_account ||= Account.find_by!(subdomain: request.subdomain)
    end
    helper_method :current_account

    def owner?
      current_account.owner == current_user
    end
    helper_method :owner?

    private

    def authorize_user!
      authenticate_user!
      unless current_account.owner == current_user || 
             current_account.users.exists?(current_user.id)
        flash[:notice] = "You are not permitted to view that account."
        redirect_to root_url(subdomain: nil)
      end
    end

    def authorize_owner!
      unless owner?
        flash[:alert] = "Only an owner of an account can do that."
        redirect_to root_url(subdomain: current_account.subdomain)
      end
    end

    def subscription_required!
      return unless owner?

      if current_account.stripe_subscription_id.blank?
        message = "You must subscribe to a plan before you can use your account."
        flash[:alert] = message
        redirect_to choose_plan_url
      end
    end

  end
end
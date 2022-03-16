class AccountsController < ApplicationController
  before_action :authorized

  def index
    # if user has one account, redirect to show the account
    # else, show a table and let the user pick the account to show
    redirect_to current_user.accounts.first if current_user.accounts.size == 1

    accounts  = current_user.accounts
    @accounts = helpers.format_account_list(accounts)
  end

  def show
    account = Account.find(params[:id])

    redirect_to accounts_path unless current_user.in?(account.users)

    @account_number  = account.account_number
    @account_balance = account.balance

    transfers = Transfer.where(sender_account: account,   created_at: 3.months.ago..)
    .or(Transfer.where(receiver_account: account, created_at: 3.months.ago..))
    .order(created_at: :desc)

    @transfers = helpers.format_transfer_list(account, transfers)

    @back_link = accounts_path if current_user.accounts.size > 1

    @new_transfer_link = new_account_transfer_path(account)
  end

  # TODO pagination for transfer list
end

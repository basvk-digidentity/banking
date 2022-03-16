class TransfersController < ApplicationController
    before_action :authorized

    def new
        sender_account = Account.find(params[:account_id])

        redirect_to accounts_path unless current_user.in?(sender_account.users)

        @transfer = Transfer.new(sender_account: sender_account)
        @balance  = sender_account.balance
    end

    def create
        sender_account = Account.find(params[:transfer][:sender_account_id])

        redirect_to accounts_path unless current_user.in?(sender_account.users)

        receiver_account = Account.find_by_account_number(params[:transfer][:receiver_account])

        begin
            @transfer = Funds.create_transfer(sender_account, receiver_account, params[:transfer][:amount], params[:transfer][:remark])
        rescue => exc
            error = exc.message
        end

        if @transfer.valid?
            redirect_to account_path(sender_account), notice: 'Transfer succeeded'
            return
        end

        logger.debug("transfer: #{@transfer.inspect}\nerrors: #{@transfer.errors.messages}")
        error = 'We were unable to execute the transfer'

        if @transfer.errors.include?(:base)
            error += " because #{@transfer.errors.messages_for(:base).join(", ")}."
        else
            error += ". Please review the fields below."
        end

        @balance  = sender_account.balance

        flash.now[:error] = error
        render 'new', status: 422
    end
end

module Funds
    class FundsException < Exception; end

    # Transfers funds between accounts
    #
    # @param sender_account   [Account] The account sending the funds
    # @param receiver_account [Account] The account receiving the funds
    # @param amount           [Decimal] The amount to transfer
    #
    # @return [Transfer] A Transfer object.
    # The transfer was successful if the Transfer object was persisted (e.g. new_record? == false).
    # Otherwise, its Error object will contain messages about the failure reasons.
    # Raises a FundsException on unexpected failures
    def create_transfer(sender_account, receiver_account, amount, remark)
        transfer = Transfer.new

        Account.transaction(isolation: :read_committed) do
            # load and lock both accounts with one single query to avoid potential deadlocks.
            # make sure to use the locked account objects, not the objects from the arguments
            locked_receiver_account, locked_sender_account = Account.where(id: [receiver_account.id, sender_account.id])
                                                                    .order(id: :asc)
                                                                    .lock!

            if locked_receiver_account.account_number != receiver_account.account_number
                locked_receiver_account, locked_sender_account = locked_sender_account, locked_receiver_account
            end

            transfer = Transfer.create!(
                receiver_account: locked_receiver_account,
                sender_account:   locked_sender_account,
                amount:           amount,
                remark:           remark
            )

            locked_receiver_account.update!(balance: locked_receiver_account.balance + BigDecimal(amount))
            locked_sender_account.update!(balance: locked_sender_account.balance - BigDecimal(amount))

            receiver_has_valid_balance = audit_balance(locked_receiver_account)
            sender_has_valid_balance   = audit_balance(locked_sender_account)

            if sender_has_valid_balance && receiver_has_valid_balance
                Rails.logger.info("Transferred #{amount} from #{locked_sender_account.account_number} to #{locked_receiver_account.account_number}")
            else
                # balances don't check out, rollback this transaction by raising an exception.
                Rails.logger.error("Rejected a transfer of #{amount} from #{locked_sender_account.account_number} to #{locked_receiver_account.account_number}")
                Rails.logger.error("Failed balance audit on account #{locked_sender_account.account_number}")   unless sender_has_valid_balance
                Rails.logger.error("Failed balance audit on account #{locked_receiver_account.account_number}") unless receiver_has_valid_balance

                raise FundsException.new("We are unable to execute this transfer due to a failed balance audit. Please contact customer support.")
            end
        end

        return transfer
    rescue ActiveRecord::RecordInvalid => invalid
        return invalid.record
    rescue Exception => exception
        Rails.logger.error("Failed to transfer #{amount} from #{sender_account&.account_number} to #{receiver_account&.account_number}: #{exception.message}")
        Rails.logger.debug("Traceback:\n#{exception.backtrace.join("\n")}")

        raise FundsException.new("We are currently unable to fulfill your request due to a temporary system outage. Please try again later.")
    end

    # Calculates the account balance from the transfer history and compares it to the known account balance
    #
    # @param account [Account] The account to audit
    #
    # @return [Boolean] True if the calculated balance equals the known balance, false otherwise.
    def audit_balance(account)
        balance = Transfer.where(receiver_account: account).sum(:amount) - Transfer.where(sender_account: account).sum(:amount)

        # corner case, if auditing the bank's system account, add the initial seed as it is not covered by a transfer
        # FIXME: these magic numbers should be configured, they should always match the values in seeds.rb
        balance += 1000000000 if account.account_number == '00000000'

        balance == account.balance
    end

    module_function :create_transfer
    module_function :audit_balance
end

module AccountHelper
    # Formats an array of Account object attributes into strings
    # for display in a table view.
    #
    # @param accounts [Array] Array of Account objects
    # @return [Array] An array of string arrays e.g. [['/account/1234', '12345678', '€54321']]
    def format_account_list(accounts)
        accounts.map do |account|
            [account_path(account.id), account.account_number, "€#{'%.2f' % account.balance}"]
        end
    end

    # Formats an array of Transfer objects attributes into strings
    # for display in a table view.
    #
    # @param account [Account] The account for which transfers are shown
    # @param transfers [Array] Array of Transfer objects
    # @return [Array] An array of string arrays e.g. [['20-10-2022 12:34:24', '12345678', '€100', 'thanks!']]
    def format_transfer_list(account, transfers)
        transfers.map do |transfer|
            date   = transfer.created_at.strftime('%d-%m-%Y %H:%M:%S')
            remark = transfer.remark || ''

            if account == transfer.sender_account
                account_number = transfer.receiver_account.account_number
                amount = '-(€%.2f)' % transfer.amount
            else
                account_number = transfer.sender_account.account_number
                amount = ' €%.2f' % transfer.amount
            end

            [date, account_number, amount, remark]
        end
    end
end

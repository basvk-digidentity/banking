require "test_helper"
require 'minitest/autorun'
require 'rspec/mocks/minitest_integration'

class FundsTest < ActiveSupport::TestCase
    self.use_transactional_tests = false

    test "concurrent transfers on same accounts should execute serially" do
        # This test uses ForkBreak to spin up two separate processes and synchronize them to run
        # Funds.create_transfer at the same time, to induce deadlocks, race conditions and so on.
        #
        # The first process will execute a transfer from account one to account two,
        # while the second process will execute a transfer from account two to acct_sys.
        # In a naive implementation, this will cause a wrong balance calculation of account two.
        # If the locking is not correctly implemented, it will deadlock access to acount two.
        #
        # ForkBreak emits some harmless debugger statements to STDOUT

        assert_equal(2, Transfer.count) # these come from fixtures

        ActiveRecord::Base.connection.disconnect! # let each fork_break process create its own new db connection

        process1 = run_create_transfer_in_fork_break do
            Funds.create_transfer(accounts(:one), accounts(:two), 100, 'test transfer 1')
        end

        process2 = run_create_transfer_in_fork_break do
            Funds.create_transfer(accounts(:two), accounts(:sys_acct), 100, 'test transfer 2')
        end

        # synchronize both processes and have them wait just before yielding to their blocks
        process1.run_until(:before_create_transfer).wait
        process2.run_until(:before_create_transfer).wait

        # execute process blocks simultaneously
        process1.run_until(:after_create_transfer)
        process2.run_until(:after_create_transfer)

        # wait for each process to finish
        process1.finish.wait
        process2.finish.wait

        ActiveRecord::Base.establish_connection # reconnect to the db
        assert_equal(4, Transfer.count) # and check if both transfers were added to the db (meaning they were successful)
    end

    private

    def run_create_transfer_in_fork_break(&block)
        ForkBreak::Process.new do  |breakpoints|
            ActiveRecord::Base.establish_connection

            original_create_transfer = Funds.method(:create_transfer)

            expect(Funds).to receive(:create_transfer) do |*args|
                breakpoints << :before_create_transfer
                transfer = original_create_transfer.call(*args)
                breakpoints << :after_create_transfer
                transfer
            end

            yield
        end
    end
end

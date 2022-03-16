# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

bank = User.find_by_login('bank') || User.create(name: 'bank', login: 'bank', password: 'horse battery staple', password_confirmation: 'horse battery staple')
bank.accounts.create(account_number: '00000000', balance: 1000000000) unless bank.accounts.find_by_account_number('0')

testuser = User.find_by_login('testuser') || User.create(name: 'testuser', login: 'testuser', password: 'testtest', password_confirmation: 'testtest')
testuser.accounts.create(account_number: '12345678', balance: 0) unless bank.accounts.find_by_account_number('12345678')
testuser.accounts.create(account_number: '87654321', balance: 0) unless bank.accounts.find_by_account_number('87654321')

Funds.create_transfer(bank.accounts.first, testuser.accounts.first, 100000, 'cash deposit')

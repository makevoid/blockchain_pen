class Wallet
  include RModel

  attr_accessor :address, :balance

  def initialize(address:, balance:)
    @address = address
    @balance = balance
  end

  TEST = ->{ Wallet.new address: "1asd", balance: 10_000 }
end


# test
# w = Wallet::TEST.(); puts w.attributes

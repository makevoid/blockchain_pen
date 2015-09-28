class PrivateKey
  def initialize(key)
    @key = `new bitcore.PrivateKey(key)`
  end

  def address
    key = @key
    `key.toAddress()`
  end

  def address_str
    address = self.address
    `address.toString()`
  end
end

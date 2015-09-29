class Pen
  extend DebugHelpers

  def self.pvt_key
    "L1dkBEcCKUdbn5xgmgmeJWJYE6jWb1UmiwQJjet2ZuQPrYLHoKKM" # 1PzTDHe2GKjv2sHHKoN4Gbu2njLtekkYHh
  end

  def self.write(message)
    log "stylus - preparing to write: #{message}"
    bitcore = BitCore.new(pvt_key)
    bitcore.op_return message, self.callback_write
  end

  def self.callback_write
    -> (tx_id) do
      log 'stylus - wrote message! tx_id:', tx_id
    end
  end

end

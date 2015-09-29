class Pen
  extend DebugHelpers

  def self.pvt_key
    "L1dkBEcCKUdbn5xgmgmeJWJYE6jWb1UmiwQJjet2ZuQPrYLHoKKM" # 1PzTDHe2GKjv2sHHKoN4Gbu2njLtekkYHh
  end

  def self.write(message, callback)
    log "stylus - preparing to write: #{message}"
    bitcore = BitCore.new(pvt_key)
    bitcore.op_return message, self.callback_write(callback)
  end

  def self.callback_write(callback)
    -> (tx_id) do
      log 'stylus - wrote message! tx_id:', tx_id
      log "https://live.blockcypher.com/btc/tx/#{tx_id}"
      log "https://blockchain.info/tx/#{tx_id}"
      callback.(tx_id)
    end
  end

end

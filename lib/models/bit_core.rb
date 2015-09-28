require 'native'

class BitCore
  include DebugHelpers

  def initialize(pvt_key_string)
    @pvt_key_string = pvt_key_string
    @pvt_key = PrivateKey.new pvt_key_string
    log 'pvt key', @pvt_key
    @address = @pvt_key.address_str
    log 'address', @address
  end

  def sign_and_broadcast
    -> (message, utxos) do
      log "sign and broadcast"

      utxos = hashes_convert utxos

      log "utxo_size", utxos.size
      utxos_out = []

      utxos.each do |utxo|
        amount_satoshis = utxo["value"]
        amount_btc = `new bitcore.Unit.fromSatoshis(amount_satoshis).BTC`
        log amount_btc
        utxos_out.push({
          address:      @address,
          txId:         utxo["tx_hash_big_endian"],
          scriptPubKey: utxo["script"],
          amount:       amount_btc,
          vout:         utxo["tx_output_n"],
        })
      end

      unless utxos.empty?
        fee = 8000 # from 5000 it should be a good fee
        utxos_out = utxos_out.to_n
        address = @address
        amount = 1000 # ??? recheck
        pvt_key = @pvt_key_string
        # message # the most important

        transaction = `new bitcore.Transaction()
          .from(utxos_out)
          .to(address, amount)
          .change(address)
          .fee(fee)
          .addData(message)
          .sign(pvt_key)`

        # log transaction
        tx_hash = `transaction.serialize()`
        log tx_hash

        Blockchain.pushtx tx_hash, self.pushtx_callback

        # try {
        #
        #   txHash = transaction.serialize();
        # } catch(error) {
        #
        #   reject({
        #     'message': 'Error serializing the transaction: ' + error.message
        #   });
        # }

      else
        log "ERROR: Not enough UTXOs"
      end

      log "END"

    end
  end

  def pushtx_callback
    -> (tx_id) do
      log "received tx_id:", tx_id
      log "TX pushed!!!"
      log "https://live.blockcypher.com/btc/tx/#{tx_id}"
      log "https://chain.so/tx/BTC/#{tx_id}"
    end
  end

  def received_utxo(message)
    -> (utxo) do
      log "received UTXO:", utxo
      self.sign_and_broadcast.(message, utxo)
    end
  end

  def op_return(message, callback)
    Blockchain.utxo @address, self.received_utxo(message)


    # var privateKey = ;
    # var utxo = {
    #   "txId" : "115e8f72f39fad874cfab0deed11a80f24f967a84079fb56ddf53ea02e308986",
    #   "outputIndex" : 0,
    #   "address" : "
    # 17XBj6iFEsf8kzDMGQk5ghZipxX49VXuaV
    # ",
    #   "script" : "76a91447862fe165e6121af80d5dde1ecb478ed170565b88ac",
    #   "satoshis" : 50000
    # };
    #
    # var transaction = new bitcore.Transaction()
    #     .from(utxo)
    #     .addData('antani')
    #     .sign(privateKey);
  end

  # TODO: use require 'json'; JSON.parse; zepto get
  def hashes_convert(array)
    Array.new(array).map do |elem|
      Hash.new elem
    end
  end


end

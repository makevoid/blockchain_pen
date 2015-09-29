require 'native'
require 'json'

class BitCore
  include DebugHelpers

  TX_FEE = 8000

  def initialize(pvt_key_string)
    @pvt_key_string = pvt_key_string
    @pvt_key = PrivateKey.new pvt_key_string
    log 'pvt key', @pvt_key
    @address = @pvt_key.address_str
    log 'address', @address
  end

  def sign_and_broadcast
    -> (message, utxos, callback) do
      log "sign and broadcast"
      tx_amount = 1000

      utxos = hashes_convert utxos

      log "utxo_size", utxos.size
      utxos_out = []
      total_amount_sathoshis = 0

      # TODO: save utxo used in local storage if the transaction succeeded in cache for 2 minutes
      # lock utxo and don't reuse it

      utxos.each do |utxo|
        amount_satoshis = utxo["value"]
        total_amount_sathoshis += amount_satoshis
        amount_btc = `new bitcore.Unit.fromSatoshis(amount_satoshis).BTC`
        log amount_btc
        tx_id = utxo["tx_hash_big_endian"]

        if store.utxos && JSON.parse(store.utxos).include?(tx_id)
          log "skipping transaction: #{tx_id}"
          next
        end

        utxos_out.push({
          address:      @address,
          txId:         tx_id,
          scriptPubKey: utxo["script"],
          amount:       amount_btc,
          vout:         utxo["tx_output_n"],
        })
        break if amount_satoshis > TX_FEE+tx_amount
      end
      log "utxos_out:",  utxos_out.size

      unless utxos.empty?
        fee = TX_FEE # from 5000 it should be a good fee
        utxos_out = utxos_out.to_n
        address = @address
        amount  = tx_amount
        pvt_key = @pvt_key_string
        log "utxos_out: ", utxos_out

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

        Blockchain.pushtx tx_hash, self.pushtx_callback(utxos_out, callback)

        # TODO:
        #
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

  def pushtx_callback(utxos_out, callback)
    -> (tx_id) do
      log "save in localStorage", tx_id
      log "utxos_out: ", utxos_out

      utxos = store.utxos ? JSON.parse(store.utxos) : []
      utxos = utxos + utxos_out.map{ |utxo| `utxo.txId` }
      store.utxos = utxos.to_json

      log "received tx_id:", tx_id
      log "TX pushed!!!"

      callback.(tx_id)
    end
  end

  def received_utxo(message, callback)
    -> (utxo) do
      log "received UTXO:", utxo
      self.sign_and_broadcast.(message, utxo, callback)
    end
  end

  def op_return(message, callback)
    Blockchain.utxo @address, self.received_utxo(message, callback)
  end

  def store
    Native(`localStorage`)
  end

  # TODO: use require 'json'; JSON.parse; zepto get
  def hashes_convert(array)
    Array.new(array).map do |elem|
      Hash.new elem
    end
  end


end

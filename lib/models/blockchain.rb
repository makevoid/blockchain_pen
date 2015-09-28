class Blockchain

  def self.utxo(address, callback)
    `console.log(address)`
    utxo_url = "https://blockchain.info/unspent?active=#{address}&format=json&cors=true"

    HTTP.get utxo_url, self.utxo_callback(callback)
  end

  def self.utxo_callback(callback)
    -> (utxo) do
      `callback(utxo.unspent_outputs)`
    end
  end

  def self.pushtx(tx_hash, callback)
    pushtx_url = "https://api.blockcypher.com/v1/btc/main/txs/push"
    post_params = { tx: tx_hash }.to_n
    # pushtx_url = "https://insight.bitpay.com/api/tx/send"
    # post_params = { rawtx: tx_hash }.to_n
    HTTP.post pushtx_url, post_params, self.pushtx_callback(callback)
  end

  def self.pushtx_callback(callback)
    -> (tx_info) do
      `console.log("TX INFO", tx_info)`
      `callback(tx_info.hash)`
    end
  end

end

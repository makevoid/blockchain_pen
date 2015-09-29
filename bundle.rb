`console.log("loading app environment")`

`self.$require("browser");`
`self.$require("browser/http");`

`window.bitcore = require('bitcore')`

class HTTP
  def self.get(url, callback)
    `$.getJSON(url, function(data){
      console.log("GET", url)
      callback(data)
    })`
  end

  def self.post(url, params, callback)
    # console.log
    # url = "/test"
    `var success = function(data){
      console.log("POST", url)
      callback(data)
    }`


    `var data = {
      tx: params.tx
    }


    console.log(JSON.stringify(data))
    `


    `ajax = {
      contentType: 'application/json',
      data: JSON.stringify(data),
      dataType: 'json',
      processData: false,
      type: 'POST',
      success: success,
      url: url
    }`


    `$.ajax(ajax)`

    # `$.ajax(url, ajax, function(data){
    #   console.log("POST", url)
    #   callback(data)
    # })`
  end
end

module RModel
  def attributes
    attrs = instance_variables.map{ |a| a.to_s[1..-1] }
    (attrs - ["constructor", "toString"]).map(&:to_sym)
  end
end

module DebugHelpers
  def log(*mex)
    if mex.size == 1
      `console.log(mex[0])`
    else
      `console.log(mex[0], mex[1])`
    end
  end
end

module UIHelpers
  extend DebugHelpers
  include DebugHelpers

  def q(selector)
    `document.querySelector(selector)`
  end

  def write(elem, content)
    `#{elem}.innerHTML = '#{content}'`
  end
end

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

require 'native'

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
    -> (message, utxos) do
      log "sign and broadcast"

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
        utxos_out.push({
          address:      @address,
          txId:         utxo["tx_hash_big_endian"],
          scriptPubKey: utxo["script"],
          amount:       amount_btc,
          vout:         utxo["tx_output_n"],
        })
        break if amount_satoshis > TX_FEE
      end
      log "utxos_out:",  utxos_out.size

      unless utxos.empty?
        fee = TX_FEE # from 5000 it should be a good fee
        utxos_out = utxos_out.to_n
        address = @address
        amount  = 1000
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

class Hasher

  def self.hash_file

  end

  def self.hash(file)

   `

    reader = new FileReader();
    reader.onload = function(data) {
      window.crypto.subtle.digest(
        {
            name: "SHA-256",
        },
        data
      )
      .then(function(hash){
        console.log(new Uint8Array(hash))
      })
      .catch(function(err){
          console.error(err)
      })
    }
    reader.readAsArrayBuffer(file)

    `
  end

end

class MessageForm
  include React::Component
  extend DebugHelpers
  extend UIHelpers
  include UIHelpers

  define_state(:chars)  { 0 }
  define_state(:submit_disabled)  { false }

  MAX_CHARS = 75

  def write
    log "writing message: #{self.message}"
    Pen.write self.message
  end

  def message
    # mex = q "input[name=message]"
    `document.querySelector("input[name=message]").value`
  end

  def update_counter
    self.chars = String.new(message).size
    self.submit_disabled = true if self.chars > MAX_CHARS
  end

  def render
    div className: "message_input" do
      div className: "row align-right" do
        span do
          self.chars
        end
        span do
          " / #{MAX_CHARS} chars"
        end
      end
      spacer
      div className: "row" do
        div className: "five columns" do
          input(name: "message", placeholder: "your important message...", type: "text")
            .on(:change){ update_counter }
        end
        div className: "one columns" do
          button(disabled: self.submit_disabled) do
            "Write"
          end.on(:click){ write }
        end
      end
    end
  end

  def spacer
    div className: "spacer10"
  end
end

class FileForm
  include React::Component
  extend DebugHelpers

  define_state(:submit_disabled)  { false }

  def hash_file
   Hasher.hash `document.querySelector("input[name=file]").files[0]`
   `console.log("hash file called!!!")`
  end

  def render
    div className: "message_input" do
      div className: "row" do
        div className: "five columns" do
          input name: "file", type: "file"
        end
        div className: "one columns" do
          button(disabled: self.submit_disabled) do
            "Write hash"
          end.on(:click){ hash_file }
        end
      end
    end
  end
end

class Success
  include React::Component

  define_state(:tx_id) { "" }

  def render
    div className: "success" do
      p "Message written:"
      p self.tx_id
    end
  end
end

class BCPen
  include React::Component

  def render
    div className: "bc_stylus" do
      present MessageForm
      # present FileForm # alpha
    end
  end
end

extend UIHelpers

log "loading app.rb"

content = q ".content"

React.render(
  React.create_element(BCPen),
  `content`
)

require_relative "config/env_server"

require 'net/http'

class BCStylus < Roda

  plugin :static, %w( /dist /vendor /css /img ), root: APP_PATH

  route do |r|
    # GET / request
    r.root do
      File.read "./index.html"
    end

    r.on "test" do
      r.is do
        r.post do
          tx_hash = request.params["tx"]
          uri = URI "https://api.blockcypher.com/v1/btc/main/txs/push"
          response = Net::HTTP.post_form uri, { tx: tx_hash }
          response.body
        end
      end
    end
  end
end

# curl https://api.chain.com/v2/bitcoin/transactions/send \
#   -u 'b5b36a4b727f5735e5559de28892bfc3:API-KEY-SECRET' \
#   -d '{"signed_hex": "0100000001pk..."}' \
#   -X POST

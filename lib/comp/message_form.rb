class MessageForm
  include React::Component
  extend DebugHelpers
  extend UIHelpers
  include UIHelpers

  define_state(:chars)  { 0 }
  define_state(:submit_disabled)  { false }
  define_state(:tx_id)  { nil }

  MAX_CHARS = 75

  def write
    log "writing message: #{self.message}"
    Pen.write self.message, self.callback_write
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
      if self.tx_id
        div className: "row" do
          div className: "spacer30"
          div { "the message has been written: #{self.tx_id}" }
          div do
            a href: "https://live.blockcypher.com/btc/tx/#{self.tx_id}" do
              "live.blockcypher.com/btc/tx/#{self.tx_id}"
            end
          end
          div do
            a href: "https://blockchain.info/tx/#{self.tx_id}" do
              "blockchain.info/tx/#{self.tx_id}"
            end
          end
        end
      end
    end
  end

  def callback_write
    -> (tx_id) do
      self.tx_id = tx_id
    end
  end

  def spacer
    div className: "spacer10"
  end
end

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
    Stylus.write self.message
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
    div className: "message_input six columns" do
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

class MessageForm
  include React::Component
  extend DebugHelpers
  extend UIHelpers
  include UIHelpers

  def write
    log "writing message: #{self.message}"
    Stylus.write self.message
  end

  def message
    # mex = q "input[name=message]"
    `document.querySelector("input[name=message]").value`
  end

  def render
    div className: "message_input six columns" do
      div className: "row" do
        div className: "five columns" do
          input name: "message", placeholder: "your important message...", type: "text"
        end
        div className: "one columns" do
          button do
            "Write"
          end.on(:click){ write }
        end
      end
    end
  end
end

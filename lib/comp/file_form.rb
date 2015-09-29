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

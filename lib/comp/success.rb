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

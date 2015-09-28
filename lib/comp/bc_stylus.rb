class BCStylus
  include React::Component

  def render
    div className: "bc_stylus" do
      present MessageForm
    end
  end
end

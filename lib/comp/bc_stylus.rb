class BCStylus
  include React::Component

  def render
    div className: "bc_stylus" do
      present MessageForm
      # present FileForm # alpha
    end
  end
end

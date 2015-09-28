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

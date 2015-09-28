module RModel
  def attributes
    attrs = instance_variables.map{ |a| a.to_s[1..-1] }
    (attrs - ["constructor", "toString"]).map(&:to_sym)
  end
end

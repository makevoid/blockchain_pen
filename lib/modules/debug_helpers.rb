module DebugHelpers
  def log(*mex)
    if mex.size == 1
      `console.log(mex[0])`
    else
      `console.log(mex[0], mex[1])`
    end
  end
end

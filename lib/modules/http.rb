class HTTP
  def self.get(url, callback)
    `$.getJSON(url, function(data){
      console.log("GET", url)
      callback(data)
    })`
  end

  def self.post(url, params, callback)
    # console.log
    url = "/test"
    `$.post(url, params, function(data){
      console.log("POST", url)
      callback(data)
    })`
  end
end

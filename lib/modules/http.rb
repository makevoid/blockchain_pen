class HTTP
  def self.get(url, callback)
    `$.getJSON(url, function(data){
      console.log("GET", url)
      callback(data)
    })`
  end

  def self.post(url, params, callback)
    # console.log
    # url = "/test"
    `var success = function(data){
      console.log("POST", url)
      callback(data)
    }`


    `var data = {
      tx: params.tx
    }


    console.log(JSON.stringify(data))
    `


    `ajax = {
      contentType: 'application/json',
      data: JSON.stringify(data),
      dataType: 'json',
      processData: false,
      type: 'POST',
      success: success,
      url: url
    }`


    `$.ajax(ajax)`

    # `$.ajax(url, ajax, function(data){
    #   console.log("POST", url)
    #   callback(data)
    # })`
  end
end

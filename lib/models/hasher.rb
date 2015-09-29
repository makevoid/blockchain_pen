class Hasher

  def self.hash_file

  end

  def self.hash(file)

   `

    reader = new FileReader();
    reader.onload = function(data) {
      window.crypto.subtle.digest(
        {
            name: "SHA-256",
        },
        data
      )
      .then(function(hash){
        console.log(new Uint8Array(hash))
      })
      .catch(function(err){
          console.error(err)
      })
    }
    reader.readAsArrayBuffer(file)

    `
  end

end

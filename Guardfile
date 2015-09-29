# create an rb bundle

CONCAT_FILES = %w(
  config/env
  lib/modules/http
  lib/modules/rmodel
  lib/modules/debug_helpers
  lib/modules/ui_helpers
  lib/models/blockchain
  lib/models/private_key
  lib/models/bit_core
  lib/models/pen
  lib/models/wallet
  lib/models/hasher
  lib/comp/message_form
  lib/comp/file_form
  lib/comp/success
  lib/comp/bc_stylus
  app
)

BUNDLE = "bundle.rb"

# :concat, type: "rb", files: files, input_dir: "lib", output: "dist/bundle" do

guard :shell do
  watch /^(?!bundle)(.+)\.rb$/ do |m|
    puts "bundling........."
    bundle = []
    for file in CONCAT_FILES
      bundle << File.read("#{file}.rb")
    end
    File.open(BUNDLE, "w"){ |f| f.write bundle.join("\n") }
    puts "bundled!"
  end
end

guard :shell do
  watch %r{^#{BUNDLE}$} do |m|
    puts "building........."
    puts `ruby build.rb`
    puts "#{m[0]} changed, regenerated opal bundle"
    puts "built!"
    puts
    puts
  end
end

guard :sass, input: "style", output: "css"

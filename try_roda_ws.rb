require 'roda'
require 'faye'
require 'faye/websocket'

class App < Roda

  PUBLIC_ROOT = File.expand_path "../", __FILE__
  plugin :static, %w( /dist /vendor /css ), root: PUBLIC_ROOT
  plugin :websockets, adapter: :thin, ping: 45


  MUTEX = Mutex.new
  ROOMS = {}

  def sync
    MUTEX.synchronize{yield}
  end

  # TODO: add opal and react rb


  route do |r|
    r.root do
      # r.get "test" do
      File.read "./index.html"
    end


    r.get "room/:d" do |room_id|
      room = sync{ROOMS[room_id] ||= []}

      r.websocket do |ws|
        # Routing block taken if request is a websocket request,
        # yields a Faye::WebSocket instance

        ws.on(:message) do |event|
          sync{room.dup}.each{|user| user.send event.data}
        end

        ws.on(:close) do |event|
          sync{room.delete(ws)}
          sync{room.dup}.each{|user| user.send "Someone left"}
        end

        sync{room.dup}.each{|user| user.send "Someone joined"}
        sync{room.push(ws)}
      end

      # If the request is not a websocket request, execution
      # continues, similar to how routing in general works.
      view 'room'
    end
  end
end

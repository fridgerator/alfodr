require "./src/alfodr"

class HelloController < Alfodr::Controller::Base
  def index
    {ok: "ok"}.to_json
  end
end

class ChatChannel < Alfodr::WebSockets::Channel
  def handle_joined(client_socket, message)
    pp "joined #{message}"
  end

  def handle_message(client_socket, msg)
    pp "msg : #{msg}"
  end

  def handle_leave(client_socket)
    pp "left"
  end
end

struct ChatSocket < Alfodr::WebSockets::ClientSocket
  channel "chat_room:*", ChatChannel

  def on_connect
    pp "connected"
    true
  end
end


Alfodr::Server.configure do
  pipeline :api do

  end

  routes :api do
    get "/", HelloController, :index
    websocket "/location", ChatSocket
  end
end

Alfodr::Server.start

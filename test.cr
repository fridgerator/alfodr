require "./src/alfodr"

class HelloController < Alfodr::Controller::Base
  def index
    {ok: "ok"}.to_json
  end
end

Alfodr::Server.configure do
  pipeline :api do

  end

  routes :api do
    get "/", HelloController, :index
  end
end

Alfodr::Server.start

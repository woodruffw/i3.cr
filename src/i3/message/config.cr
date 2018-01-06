require "json"

module I3
  class Message
    # Represents the response to a `Message::MessageType::GET_CONFIG` request.
    #
    # See `Connection#config`.
    class Config
      JSON.mapping(
        config: String,
      )
    end
  end
end

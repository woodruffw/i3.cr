require "json"

module I3
  class Message
    # Represents one element of the response to a `Message::MessageType::GET_OUTPUTS` request.
    #
    # See `Connection#outputs`.
    class Output
      JSON.mapping(
        name: String,
        active: Bool,
        primary: Bool,
        current_workspace: String?,
        rect: Rect,
      )
    end
  end
end

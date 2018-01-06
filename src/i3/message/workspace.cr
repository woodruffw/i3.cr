require "json"

module I3
  class Message
    # Represents one element of the response to a `Message::MessageType::GET_WORKSPACES` request.
    #
    # See `Connection#workspaces`.
    class Workspace
      JSON.mapping(
        num: Int32,
        name: String,
        visible: Bool,
        focused: Bool,
        urgent: Bool,
        rect: Rect,
        output: String,
      )
    end
  end
end

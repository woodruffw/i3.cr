require "json"

module I3
  class Message
    # Represents a status code returned by various requests.
    class Status
      JSON.mapping(
        success: Bool,
        error: String?,
      )
    end
  end
end

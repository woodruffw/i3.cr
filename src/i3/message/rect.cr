require "json"

module I3
  class Message
    # Represents a window or container's "rect": X and Y coordinates, plus width and height.
    class Rect
      JSON.mapping(
        x: Int32,
        y: Int32,
        width: Int32,
        height: Int32,
      )
    end
  end
end

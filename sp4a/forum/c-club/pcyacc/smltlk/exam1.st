     
center: aPoint

  "returns the center of the receiver and aPoint"

  | center  |

  center <- Point new .
  center setX: (self x + aPoint x) / 2 .
  center setY: (self y + aPoint y) / 2 .
  ^ center


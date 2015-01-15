# Array of possible suits (D)iamonds, (C)lubs, (H)earts, && (S)pades
class CardSuits < Array
  def initialize
    self[0] = "D"
    self[1] = "C"
    self[2] = "H"
    self[3] = "S"
  end
end

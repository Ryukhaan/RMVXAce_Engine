# [73] 53795570: Window_ShopCommand
#==============================================================================
# ** Window_ShopCommand
#------------------------------------------------------------------------------
#  This window is for selecting buy/sell on the shop screen.
#==============================================================================
module Vocab
  ShopRepair = "Réparer"
end

class Window_ShopCommand < Window_HorzCommand
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::ShopBuy,    :buy)
    add_command(Vocab::ShopRepair, :repair)
    add_command(Vocab::ShopSell,   :sell,   !@purchase_only)
    add_command(Vocab::ShopCancel, :cancel)
  end
end
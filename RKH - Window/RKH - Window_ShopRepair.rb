class Window_EquipRepair < Window_Selectable
  def enable?(item)
    return true if item.is_a?(RPG::Weapon) && $game_party.gold >=  item.price
    return false
  end
  
  def update_help
    unless item
      @help_window.set_text("Aucun objet seletionné")
    else
      if item.price.zero?
        @help_window.set_text("Non reparabe")
      else
        @help_window.set_text("Coute " + item.price.to_s + Vocab.currency_unit)
      end
    end
  end
  
  #def include?(item)
  #  !item.is_a?(RPG::Item) && !item.nil? && item.use_durability
  #end
end
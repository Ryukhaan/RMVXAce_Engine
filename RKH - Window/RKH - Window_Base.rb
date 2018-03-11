class Window_Base < Window
   
  def iniatilze(x, y, width, height)
    super
    self.windowskin = Cache.system("Window")
    self.back_opacity = 255
    self.tone = Tone.new(255, 255, 255, 255)
    update_padding
    update_tone
    create_contents
    @opening = @closing = false
  end
  
  def update_tone
    self.tone.set(Tone.new(255, 255, 255, 255))
    self.back_opacity = 255
  end

  #--------------------------------------------------------------------------
  # * Draw Face Graphic
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def draw_face(face_name, face_index, x, y, enabled = true)
    bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    #rect = Rect.new(face_index % 6 * 64, face_index / 6 * 64, 64, 64)
    contents.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
    bitmap.dispose
  end
  
    def normal_color;      text_color(0);   end;    # Normal
  def system_color;      text_color(0);  end;    # System
  def crisis_color;      text_color(0);  end;    # Crisis
  def knockout_color;    text_color(0);  end;    # Knock out
  def gauge_back_color;  text_color(0);  end;    # Gauge background
  def hp_gauge_color1;   text_color(0);  end;    # HP gauge 1
  def hp_gauge_color2;   text_color(0);  end;    # HP gauge 2
  def mp_gauge_color1;   text_color(0);  end;    # MP gauge 1
  def mp_gauge_color2;   text_color(0);  end;    # MP gauge 2
  def mp_cost_color;     text_color(0);  end;    # TP cost
  def power_up_color;    text_color(0);  end;    # Equipment power up
  def power_down_color;  text_color(0);  end;    # Equipment power down
  def tp_gauge_color1;   text_color(0);  end;    # TP gauge 1
  def tp_gauge_color2;   text_color(0);  end;    # TP gauge 2
  def tp_cost_color;     text_color(0);  end;    # TP cost
  
end
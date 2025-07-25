defmodule ExFTMS.TrainingStatus do
  @moduledoc false

  def training_status_from_atom(atom) do
    case atom do
      :other -> 0x00
      :idle -> 0x01
      :warming_up -> 0x02
      :low_intensity_interval -> 0x03
      :high_intensity_interval -> 0x04
      :recovery_interval -> 0x05
      :isometric -> 0x06
      :heart_rate_control -> 0x07
      :fitness_test -> 0x08
      :speed_lower_than_control_region -> 0x09
      :speed_higher_than_control_region -> 0x0A
      :cool_down -> 0x0B
      :watt_control -> 0x0C
      :manual_mode -> 0x0D
      :pre_workout -> 0x0E
      :post_workout -> 0x0F
      :rfu -> 0xFF
    end
  end

  def training_status_to_atom(hex) when hex >= 0x00 and hex <= 0xFF do
    case hex do
      0x00 -> :other
      0x01 -> :idle
      0x02 -> :warming_up
      0x03 -> :low_intensity_interval
      0x04 -> :high_intensity_interval
      0x05 -> :recovery_interval
      0x06 -> :isometric
      0x07 -> :heart_rate_control
      0x08 -> :fitness_test
      0x09 -> :speed_lower_than_control_region
      0x0A -> :speed_higher_than_control_region
      0x0B -> :cool_down
      0x0C -> :watt_control
      0x0D -> :manual_mode
      0x0E -> :pre_workout
      0x0F -> :post_workout
      _ -> :rfu
    end
  end
end

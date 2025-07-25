defmodule ExFTMS.FitnessMachineFeature do
  @moduledoc false

  # the gettable features
  def fitness_machine_features(%ExFTMS.StairClimberData{} = sample_data) do
    # hard coded zeroes are unused in stair climbers
    avg_speed = 0
    cadence = 0
    total_distance = 0
    inclination = 0

    elevation_gain = if sample_data.elevation_gain, do: 1, else: 0
    pace = 0
    step_count = if sample_data.spm || sample_data.avg_step_rate, do: 1, else: 0
    resistance_level = 0

    byte1 =
      <<resistance_level::1, step_count::1, pace::1, elevation_gain::1, inclination::1,
        total_distance::1, cadence::1, avg_speed::1>>

    stride_count = if sample_data.stride_count, do: 1, else: 0

    expended_energy =
      if sample_data.total_energy || sample_data.energy_per_hour || sample_data.energy_per_minute,
        do: 1,
        else: 0

    heart_rate_measurement = if sample_data.hr, do: 1, else: 0
    metabolic_equivalent = if sample_data.met, do: 1, else: 0
    elapsed_time = if sample_data.elapsed_time, do: 1, else: 0
    remaining_time = if sample_data.remaining_time, do: 1, else: 0
    power_measurement = 0
    force_on_belt_and_power_output = 0

    byte2 =
      <<force_on_belt_and_power_output::1, power_measurement::1, remaining_time::1,
        elapsed_time::1, metabolic_equivalent::1, heart_rate_measurement::1, expended_energy::1,
        stride_count::1>>

    user_data_retention = 0
    rfu_7_bits = 0

    rfu_8_bits = 0

    <<byte1::binary, byte2::binary, user_data_retention::1, rfu_7_bits::7, rfu_8_bits::8>>
  end

  # the settable features
  def target_setting_features(:hardcoded) do
    set_speed_target = 0
    set_inclination_target = 0
    set_resistance_target = 0
    set_power_target = 0
    set_heart_rate_target = 0
    set_expended_energy_target = 0
    set_step_number_target = 0
    set_stride_number_target = 0

    byte1 =
      <<set_stride_number_target::1, set_step_number_target::1, set_expended_energy_target::1,
        set_heart_rate_target::1, set_power_target::1, set_resistance_target::1,
        set_inclination_target::1, set_speed_target::1>>

    set_distance_target = 0
    set_training_time_target = 0
    set_time_in_two_heart_rate_zones_target = 0
    set_time_in_three_heart_rate_zones_target = 0
    set_time_in_five_heart_rate_zones_target = 0
    set_indoor_bike_simulation_parameters = 0
    set_wheel_circumference = 0
    set_spin_down = 0

    byte2 =
      <<set_spin_down::1, set_wheel_circumference::1, set_indoor_bike_simulation_parameters::1,
        set_time_in_five_heart_rate_zones_target::1, set_time_in_three_heart_rate_zones_target::1,
        set_time_in_two_heart_rate_zones_target::1, set_training_time_target::1,
        set_distance_target::1>>

    set_cadence_target = 0
    set_rfu_7_bits = 0

    byte3 = <<set_rfu_7_bits::7, set_cadence_target::1>>

    set_rfu_8_bits = 0
    byte4 = <<set_rfu_8_bits::8>>

    <<byte1::binary, byte2::binary, byte3::binary, byte4::binary>>
  end
end

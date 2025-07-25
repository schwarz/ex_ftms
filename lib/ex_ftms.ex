defmodule ExFTMS do
  @moduledoc """
  Documentation for `ExFTMS`.
  """

  @fitness_machine_types [
    :treadmill,
    :cross_trainer,
    :step_climber,
    :stair_climber,
    :rower,
    :indoor_bike
  ]

  @training_states [
    :other,
    :idle,
    :warming_up,
    :low_intensity_interval,
    :high_intensity_interval,
    :recovery_interval,
    :isometric,
    :heart_rate_control,
    :fitness_test,
    :speed_lower_than_control_region,
    :speed_higher_than_control_region,
    :cool_down,
    :watt_control,
    :manual_mode,
    :pre_workout,
    :post_workout,
    :rfu
  ]

  @type training_status ::
          :other
          | :idle
          | :warming_up
          | :low_intensity_interval
          | :high_intensity_interval
          | :recovery_interval
          | :isometric
          | :heart_rate_control
          | :fitness_test
          | :speed_lower_than_control_region
          | :speed_higher_than_control_region
          | :cool_down
          | :watt_control
          | :manual_mode
          | :pre_workout
          | :post_workout
          | :rfu

  @doc """
  Returns a AD binary (length - type - value) as defined in the FTMS spec.
  Simply include this in your advertising data.

  This LTV takes up 7 bytes.

  `type` is the fitness machine type (`:treadmill`, `:cross_trainer`, ...)

      iex> ExFTMS.advertising_data(:stair_climber)
      <<6, 22, 38, 24, 1, 8, 0>>

      iex> ExFTMS.advertising_data(:stair_climber) |> Base.encode16()
      "06162618010800"
  """
  def advertising_data(type) when type in @fitness_machine_types do
    # Service Data AD Type - 0x16
    ad_type = 0x16

    # Fitness Machine Service UUID
    ftms_uuid = 0x1826

    # Flags
    fitness_machine_available = 1
    flags_rfu = 0
    flags = <<flags_rfu::7, fitness_machine_available::1>>

    # Fitness Machine Type
    fitness_machine_type =
      case type do
        :treadmill -> 1
        :cross_trainer -> 2
        :step_climber -> 4
        :stair_climber -> 8
        :rower -> 16
        :indoor_bike -> 32
      end

    except_length =
      <<ad_type::8, ftms_uuid::little-16, flags::binary, fitness_machine_type::little-16>>

    <<byte_size(except_length)::8, except_length::binary>>
  end

  @doc """
    Get the value needed for the Training Status characteristic.
    Training Status String/Extended String not supported currently.

      iex> ExFTMS.training_status(:manual_mode)
      <<0, 13>>

      iex> ExFTMS.training_status(:manual_mode) |> Base.encode16()
      "000D"
  """
  @spec training_status(training_status()) :: binary()
  def training_status(status) when status in @training_states do
    training_status_string = 0
    extended_string = 0
    flags = <<0::6, extended_string::1, training_status_string::1>>
    <<flags::binary, ExFTMS.TrainingStatus.training_status_from_atom(status)::8>>
  end

  @doc """
  Get the value needed for the Fitness Machine Features characteristic
  by passing a sample of your data.

  `sample_data` is one of

  * `%ExFTMS.StairClimberData{}`

  with all fields that your machine supports set to some non-nil value.

  This characteristic tells clients what data they can expect to receive from the fitness machine.
  Note: `ExFTMS` currently does not support target setting.

      iex> %ExFTMS.StairClimberData{
      ...>   elapsed_time: 1,
      ...>   met: 1,
      ...>   hr: 1,
      ...>   energy_per_minute: :data_not_available,
      ...>   energy_per_hour: 1,
      ...>   total_energy: 1,
      ...>   stride_count: 0,
      ...>   elevation_gain: 0,
      ...>   avg_step_rate: 20,
      ...>   spm: 20,
      ...>   floors: 0
      ...> }
      ...> |> ExFTMS.fitness_machine_features()
      ...> |> Base.encode16()
      "501F000000000000"
  """
  def fitness_machine_features(sample_data, target_sample_data \\ nil)

  def fitness_machine_features(%ExFTMS.StairClimberData{} = sample_data, nil) do
    <<ExFTMS.FitnessMachineFeature.fitness_machine_features(sample_data)::binary,
      ExFTMS.FitnessMachineFeature.target_setting_features(:hardcoded)::binary>>
  end
end

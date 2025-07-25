defmodule ExFTMS.FitnessMachineStatus do
  @moduledoc """
  The Fitness Machine Status characteristic is only needed if the server supports
  the Fitness Machine Control Point characteristic. Then it's used to communicate
  the status of the server.
  """

  def reset do
    <<0x01::8>>
  end

  def stopped do
    <<0x02::8, 0x01::8>>
  end

  def paused do
    <<0x02::8, 0x02::8>>
  end

  def stopped_by_safety_key do
    <<0x03::8>>
  end

  @doc """
  If you don't want to bother with anything else, at least send this when the
  machine is running.

      iex> ExFTMS.FitnessMachineStatus.started_or_resumed() |> Base.encode16()
      "04"
  """
  def started_or_resumed do
    <<0x04::8>>
  end

  @doc """
  Speed should be passed in km/h.

      iex> ExFTMS.FitnessMachineStatus.target_speed_changed(3.7)
      <<0x05, 37, 0>>
  """
  def target_speed_changed(speed) do
    speed = trunc(speed * 10)
    <<0x05::8, speed::little-unsigned-integer-16>>
  end

  @doc """
  Incline percent should be passed as a float from 0.0 to 1.0, so 1.5% incline would be 0.015.

      iex> ExFTMS.FitnessMachineStatus.target_incline_changed(0.037) # 3.7 % incline
      <<0x06, 37, 0>>
  """
  def target_incline_changed(percent) do
    incline = trunc(percent * 1000)
    <<0x06::8, incline::little-signed-integer-16>>
  end

  @doc """
  Resistance level as a float, e.g. 3.4

      iex> ExFTMS.FitnessMachineStatus.target_resistance_level_changed(5.0)
      <<7, 50>>
  """
  def target_resistance_level_changed(level) do
    level = trunc(level * 10)
    <<0x07::8, level::little-unsigned-integer-8>>
  end

  @doc """
  Power in Watt

      iex> ExFTMS.FitnessMachineStatus.target_power_changed(5)
      <<8, 5, 0>>
  """
  def target_power_changed(power) do
    <<0x08::8, power::little-signed-integer-16>>
  end

  @doc """
  Heart rate in beats per minute (BPM)

      iex> ExFTMS.FitnessMachineStatus.target_heart_rate_changed(150)
      <<0x09, 150>>
  """
  def target_heart_rate_changed(bpm) do
    <<0x09::8, bpm::little-unsigned-integer-8>>
  end

  @doc """
  Targeted expended energy in calories

      iex> ExFTMS.FitnessMachineStatus.targeted_expended_energy_changed(250)
      <<0x0A, 250, 0>>
  """
  def targeted_expended_energy_changed(calories) do
    <<0x0A::8, calories::little-unsigned-integer-16>>
  end

  @doc """
  Steps

      iex> ExFTMS.FitnessMachineStatus.targeted_steps_changed(255)
      <<0x0B, 255, 0>>
  """
  def targeted_steps_changed(steps) do
    <<0x0B::8, steps::little-unsigned-integer-16>>
  end

  @doc """
  Strides

      iex> ExFTMS.FitnessMachineStatus.targeted_strides_changed(255)
      <<0x0C, 255, 0>>
  """
  def targeted_strides_changed(strides) do
    <<0x0C::8, strides::little-unsigned-integer-16>>
  end

  @doc """
  Distance in meters

      iex> ExFTMS.FitnessMachineStatus.targeted_distance_changed(50)
      <<0x0D, 50, 0, 0>>
  """
  def targeted_distance_changed(meters) do
    <<0x0D::8, meters::little-unsigned-integer-24>>
  end

  @doc """
  Training time in seconds

      iex> ExFTMS.FitnessMachineStatus.targeted_training_time_changed(120)
      <<0x0E, 120, 0>>
  """
  def targeted_training_time_changed(seconds) do
    <<0x0E::8, seconds::little-unsigned-integer-16>>
  end

  @doc """
  Pass the times for the two zones in full seconds

      iex> ExFTMS.FitnessMachineStatus.targeted_training_time_in_two_heart_rate_zones_changed(10, 3)
      <<15, 10, 0, 3, 0>>
  """
  def targeted_training_time_in_two_heart_rate_zones_changed(
        seconds_in_fat_burn_zone,
        seconds_in_fitness_zone
      ) do
    <<0x0F::8, seconds_in_fat_burn_zone::little-unsigned-integer-16,
      seconds_in_fitness_zone::little-unsigned-integer-16>>
  end

  @doc """
  Pass the times for the three zones in full seconds

      iex> ExFTMS.FitnessMachineStatus.targeted_training_time_in_three_heart_rate_zones_changed(10, 3, 1)
      <<0x10, 10, 0, 3, 0, 1, 0>>
  """
  def targeted_training_time_in_three_heart_rate_zones_changed(
        seconds_in_light_zone,
        seconds_in_moderate_zone,
        seconds_in_hard_zone
      ) do
    <<0x10::8, seconds_in_light_zone::little-unsigned-integer-16,
      seconds_in_moderate_zone::little-unsigned-integer-16,
      seconds_in_hard_zone::little-unsigned-integer-16>>
  end

  @doc """
  Pass the times for the five zones in full seconds

      iex> ExFTMS.FitnessMachineStatus.targeted_training_time_in_five_heart_rate_zones_changed(1, 2, 3, 4, 5)
      <<0x11, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0>>
  """
  def targeted_training_time_in_five_heart_rate_zones_changed(
        seconds_in_very_light_zone,
        seconds_in_light_zone,
        seconds_in_moderate_zone,
        seconds_in_hard_zone,
        seconds_in_maximum_zone
      ) do
    <<0x11::8, seconds_in_very_light_zone::little-unsigned-integer-16,
      seconds_in_light_zone::little-unsigned-integer-16,
      seconds_in_moderate_zone::little-unsigned-integer-16,
      seconds_in_hard_zone::little-unsigned-integer-16,
      seconds_in_maximum_zone::little-unsigned-integer-16>>
  end

  @doc """
  Indoor Bike Simulation Parameters

  * wind_speed: m/s
  * grade: percentage
  * crr: unitless coefficient of rolling resistance
  * cw: kg/m wind resistance coefficient
  """
  def indoor_bike_simulation_parameters_changed(wind_speed, grade, crr, cw) do
    wind_speed = trunc(wind_speed * 1_000)
    grade = trunc(grade * 100)
    crr = trunc(crr * 10_000)
    cw = trunc(cw * 100)

    <<0x12::8, wind_speed::little-signed-integer-16, grade::little-signed-integer-16,
      crr::little-unsigned-integer-8, cw::little-unsigned-integer-8>>
  end

  @doc """
  Circumference in Millimeters with resolution of 0.1 Millimeter, 0.1 == 1

      iex> ExFTMS.FitnessMachineStatus.wheel_circumference_changed(280)
      <<0x13, 240, 10>>
  """
  def wheel_circumference_changed(mm) do
    mm = trunc(mm * 10)
    <<0x13::8, mm::little-unsigned-integer-16>>
  end

  @doc """
  Spin down status can be one of [:spin_down_requested, :success, :error, :stop_pedaling] or
  the raw value if you need to set a custom value (0-255).

      iex> ExFTMS.FitnessMachineStatus.spin_down_status(:success)
      <<0x14, 0x02>>
  """
  def spin_down_status(status_or_raw) do
    encoded = encode_spin_down(status_or_raw)
    <<0x14::8, encoded::8>>
  end

  @doc """
  Cadence (e.g. RPM on an indoor bike)

      iex> ExFTMS.FitnessMachineStatus.targeted_cadence_changed(90)
      <<0x15, 180, 0>>
  """
  def targeted_cadence_changed(cadence) do
    cadence = trunc(cadence * 2)
    <<0x15::8, cadence::little-unsigned-integer-16>>
  end

  @doc """
  Client has lost controlled: revoked by the user or another client has requested control.
  """
  def control_permission_lost do
    <<0xFF>>
  end

  @spec encode_spin_down(atom() | non_neg_integer()) :: non_neg_integer()
  defp encode_spin_down(status)

  defp encode_spin_down(atom) when is_atom(atom) do
    case atom do
      :spin_down_requested -> 0x01
      :success -> 0x02
      :error -> 0x03
      :stop_pedaling -> 0x04
    end
  end

  defp encode_spin_down(raw) when is_integer(raw) and raw <= 0xFF, do: raw
end

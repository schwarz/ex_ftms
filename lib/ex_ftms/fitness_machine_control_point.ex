defmodule ExFTMS.FitnessMachineControlPoint do
  @moduledoc false

  def procedure_complete(request_op, result, response_parameter \\ <<>>) do
    request_op_code = op_code_from_atom(request_op)

    result_code =
      case result do
        :rfu -> 0x00
        :success -> 0x01
        :op_code_not_supported -> 0x02
        :invalid_parameter -> 0x03
        :operation_failed -> 0x04
        :control_not_permitted -> 0x05
      end

    <<0x80::8, request_op_code::unsigned-8, result_code::unsigned-8,
      response_parameter::binary-little>>
  end

  def decode(binary) do
    case binary do
      <<0x00, _::binary>> ->
        :request_control

      <<0x01, _::binary>> ->
        :reset

      <<0x02, kmh::little-unsigned-integer-16>> ->
        # in km/h with a resolution of 0.01 km/h, 0.01 km/h = 1
        {:set_target_speed, kmh / 100.0}

      <<0x03, inclination::little-signed-integer-16>> ->
        # in Percent with a resolution of 0.1 %, 0.1% = 1
        {:set_target_inclination, inclination / 1000.0}

      <<0x04, resistance::little-unsigned-integer-8>> ->
        # unitless with a resolution of 0.1, 0.1 = 1
        {:set_target_resistance_level, resistance / 10.0}

      <<0x05, watt::little-signed-integer-16>> ->
        #  in Watt with a resolution of 1 W
        {:set_target_power, watt}

      <<0x06, bpm::little-unsigned-integer-8>> ->
        #  in BPM with a resolution of 1 BPM
        {:set_target_heart_rate, bpm}

      <<0x07>> ->
        :start_or_resume

      <<0x08, control_information::8>> ->
        case control_information do
          1 -> {:stop_or_pause, :stop}
          2 -> {:stop_or_pause, :pause}
          _ -> {:stop_or_pause, :rfu}
        end

      <<0x09, calories::little-unsigned-integer-16>> ->
        # in Calories with a resolution of 1 Calorie
        {:set_target_expended_energy, calories}

      <<0x0A, steps::little-unsigned-integer-16>> ->
        # in Steps with a resolution of 1 Step
        {:set_target_number_of_steps, steps}

      <<0x0B, strides::little-unsigned-integer-16>> ->
        # in Strides with a resolution of 1 Stride
        {:set_target_number_of_strides, strides}

      <<0x0C, meters::little-unsigned-integer-24>> ->
        # in Meters with a resolution of 1 Meter
        {:set_target_distance, meters}

      <<0x0D, seconds::little-unsigned-integer-16>> ->
        #  in Seconds with a resolution of 1 Second
        {:set_target_training_time, seconds}

      <<0x0E, seconds_in_fat_burn_zone::little-unsigned-integer-16,
        seconds_in_fitness_zone::little-unsigned-integer-16>> ->
        {:set_target_time_in_two_heart_rate_zones,
         %{
           seconds_in_fat_burn_zone: seconds_in_fat_burn_zone,
           seconds_in_fitness_zone: seconds_in_fitness_zone
         }}

      <<0x0F, seconds_in_light_zone::little-unsigned-integer-16,
        seconds_in_moderate_zone::little-unsigned-integer-16,
        seconds_in_hard_zone::little-unsigned-integer-16>> ->
        {:set_target_time_in_three_heart_rate_zones,
         %{
           seconds_in_light_zone: seconds_in_light_zone,
           seconds_in_moderate_zone: seconds_in_moderate_zone,
           seconds_in_hard_zone: seconds_in_hard_zone
         }}

      <<0x10, seconds_in_very_light_zone::little-unsigned-integer-16,
        seconds_in_light_zone::little-unsigned-integer-16,
        seconds_in_moderate_zone::little-unsigned-integer-16,
        seconds_in_hard_zone::little-unsigned-integer-16,
        seconds_in_maximum_zone::little-unsigned-integer-16>> ->
        {:set_target_time_in_five_heart_rate_zones,
         %{
           seconds_in_very_light_zone: seconds_in_very_light_zone,
           seconds_in_light_zone: seconds_in_light_zone,
           seconds_in_moderate_zone: seconds_in_moderate_zone,
           seconds_in_hard_zone: seconds_in_hard_zone,
           seconds_in_maximum_zone: seconds_in_maximum_zone
         }}

      <<0x11, wind_speed::little-signed-integer-16, grade::little-signed-integer-16,
        crr::little-unsigned-integer-8, cw::little-unsigned-integer-8>> ->
        wind_speed = wind_speed * 0.001
        grade = grade * 0.01
        crr = crr * 0.0001
        cw = cw * 0.01

        {:set_indoor_bike_simulation_parameters,
         %{wind_speed: wind_speed, grade: grade, crr: crr, cw: cw}}

      <<0x12, millimeters::little-unsigned-integer-16>> ->
        # in Millimeters with resolution of 0.1 Millimeter, 0.1 = 1
        {:set_wheel_circumference, millimeters / 10.0}

      <<0x13, control_parameter::binary>> ->
        # TODO
        {:set_spin_down_control, control_parameter}

      <<0x14, cadence::little-unsigned-integer-16>> ->
        #  in 1/minute with a resolution of 0.5 1/minute, 0.5 = 1
        {:set_target_cadence, cadence / 2.0}

      <<rfu, param::binary>> when rfu >= 0x15 and rfu <= 0x7F ->
        {{:rfu, rfu}, param}

      <<0x80, response_code::binary>> ->
        # TODO
        {:response_code, response_code}

      <<rfu, param::binary>> when rfu >= 0x81 and rfu <= 0xFF ->
        {{:rfu, rfu}, param}

      other ->
        {:error, "unknown op: #{Base.encode16(other)}"}
    end
  end

  defp op_code_from_atom(atom) do
    case atom do
      :request_control -> 0x00
      :reset -> 0x01
      :set_target_speed -> 0x02
      :set_target_inclination -> 0x03
      :set_target_resistance_level -> 0x04
      :set_target_power -> 0x05
      :set_target_heart_rate -> 0x06
      :start_or_resume -> 0x07
      :stop_or_pause -> 0x08
      :set_target_expended_energy -> 0x09
      :set_target_number_of_steps -> 0x0A
      :set_target_number_of_strides -> 0x0B
      :set_target_distance -> 0x0C
      :set_target_training_time -> 0x0D
      :set_target_time_in_two_heart_rate_zones -> 0x0E
      :set_target_time_in_three_heart_rate_zones -> 0x0F
      :set_target_time_in_five_heart_rate_zones -> 0x10
      :set_indoor_bike_simulation_parameters -> 0x11
      :set_wheel_circumference -> 0x12
      :set_spin_down_control -> 0x13
      :set_target_cadence -> 0x14
      :response_code -> 0x80
    end
  end
end

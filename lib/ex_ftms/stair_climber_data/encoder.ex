defmodule ExFTMS.StairClimberData.Encoder do
  @moduledoc false

  @flag_overhead 2
  @default_build_order [
    spm: 2,
    avg_step_rate: 2,
    elevation_gain: 2,
    stride_count: 2,
    energy_expenditure: 5,
    hr: 1,
    met: 1,
    elapsed_time: 2,
    remaining_time: 2,
    floors: 2
  ]

  @doc """
  Encode `%StairClimberData{}` into one or more binary packets.
  """
  def encode(%ExFTMS.StairClimberData{} = data, bytes_available \\ 20)
      when bytes_available >= 20 do
    chunk_fun = fn {field_name, field_cost} = element, acc ->
      accumulated_chunk_cost = Enum.sum_by(acc, &elem(&1, 1))

      if accumulated_chunk_cost > bytes_available - @flag_overhead - field_cost do
        {:cont, Enum.reverse(acc), [element]}
      else
        if field_name == :floors do
          # make :more_data/:floors end up the first of the final chunk
          {:cont, acc ++ [element]}
        else
          {:cont, [element | acc]}
        end
      end
    end

    after_fun = fn
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end

    build_order =
      Enum.filter(@default_build_order, fn {field_name, _} ->
        case field_name do
          :floors ->
            true

          :energy_expenditure ->
            # if we want one of the energy fields we must send all three
            data.total_energy || data.energy_per_hour || data.energy_per_minute

          f ->
            not is_nil(Map.get(data, f))
        end
      end)

    packets = Enum.chunk_while(build_order, [], chunk_fun, after_fun)

    Enum.map(packets, fn keys ->
      data = %{
        data
        | total_energy: replace_not_available(data.total_energy, 0xFFFF),
          energy_per_hour: replace_not_available(data.energy_per_hour, 0xFFFF),
          energy_per_minute: replace_not_available(data.energy_per_minute, 0xFF),
          met: scale_met(data.met)
      }

      Enum.reduce(keys, build_flags(keys), fn
        {:energy_expenditure, _}, acc ->
          acc <>
            encode_field_optionally(:total_energy, Map.get(data, :total_energy)) <>
            encode_field_optionally(:energy_per_hour, Map.get(data, :energy_per_hour)) <>
            encode_field_optionally(:energy_per_minute, Map.get(data, :energy_per_minute))

        {field_name, _}, acc ->
          acc <> encode_field_optionally(field_name, Map.get(data, field_name))
      end)
    end)
  end

  defp replace_not_available(value, new_value) do
    case value do
      :data_not_available -> new_value
      nil -> new_value
      v -> v
    end
  end

  defp scale_met(value) do
    case value do
      nil -> nil
      v -> floor(v * 10)
    end
  end

  defp encode_field_optionally(_, nil), do: <<>>

  defp encode_field_optionally(field_name, value) do
    case field_name do
      :floors -> <<value::unsigned-little-16>>
      :spm -> <<value::unsigned-little-16>>
      :avg_step_rate -> <<value::unsigned-little-16>>
      :elevation_gain -> <<value::unsigned-little-16>>
      :stride_count -> <<value::unsigned-little-16>>
      :total_energy -> <<value::unsigned-little-16>>
      :energy_per_hour -> <<value::unsigned-little-16>>
      :energy_per_minute -> <<value::unsigned-little-8>>
      :hr -> <<value::unsigned-little-8>>
      :met -> <<value::unsigned-little-8>>
      :elapsed_time -> <<value::unsigned-little-16>>
      :remaining_time -> <<value::unsigned-little-16>>
    end
  end

  @doc """
  Encodes a packet build order into the Stair Climber Data flags field.
  """
  def build_flags(fields) do
    more_data = if Keyword.has_key?(fields, :floors), do: 0, else: 1
    spm = if Keyword.has_key?(fields, :spm), do: 1, else: 0
    avg_step_rate = if Keyword.has_key?(fields, :avg_step_rate), do: 1, else: 0
    elevation_gain = if Keyword.has_key?(fields, :elevation_gain), do: 1, else: 0
    stride_count = if Keyword.has_key?(fields, :stride_count), do: 1, else: 0
    energy_expenditure = if Keyword.has_key?(fields, :energy_expenditure), do: 1, else: 0
    hr = if Keyword.has_key?(fields, :hr), do: 1, else: 0
    met = if Keyword.has_key?(fields, :met), do: 1, else: 0
    elapsed_time = if Keyword.has_key?(fields, :elapsed_time), do: 1, else: 0
    remaining_time = if Keyword.has_key?(fields, :remaining_time), do: 1, else: 0
    rfu = 0

    <<met::1, hr::1, energy_expenditure::1, stride_count::1, elevation_gain::1, avg_step_rate::1,
      spm::1, more_data::1, rfu::6, remaining_time::1, elapsed_time::1>>
  end
end

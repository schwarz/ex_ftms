defmodule ExFTMS.StairClimberData.Decoder do
  @moduledoc false

  def parse(<<flags::little-16, rest::binary>>) do
    flags_binary = <<flags::little-16>>

    <<met::1, hr::1, expended_energy::1, stride_count::1, elevation_gain::1, avg_step_rate::1,
      spm::1, more_data::1, _rfu::6, remaining_time::1, elapsed_time::1>> = flags_binary

    flags = [
      more_data: more_data == 1,
      spm: spm == 1,
      avg_step_rate: avg_step_rate == 1,
      elevation_gain: elevation_gain == 1,
      stride_count: stride_count == 1,
      expended_energy: expended_energy == 1,
      hr: hr == 1,
      met: met == 1,
      elapsed_time: elapsed_time == 1,
      remaining_time: remaining_time == 1
    ]

    parse(rest, %{flags: flags, fields: %{more_data: more_data == 1}})
  end

  def parse(
        <<floors::unsigned-little-16, rest::binary>>,
        %{flags: [{:more_data, false} | remaining_flags]} = context
      ) do
    parse(rest, %{
      context
      | flags: remaining_flags,
        fields: Map.put(context[:fields], :floors, floors)
    })
  end

  def parse(<<rest::binary>>, %{flags: [{:more_data, true} | remaining_flags]} = context) do
    # If the more_data flag is true we have no floors field in this packet
    parse(rest, Map.put(context, :flags, remaining_flags))
  end

  def parse(
        <<spm::unsigned-little-16, rest::binary>>,
        %{flags: [{:spm, true} | remaining_flags]} = context
      ) do
    parse(rest, %{context | flags: remaining_flags, fields: Map.put(context[:fields], :spm, spm)})
  end

  def parse(
        <<avg_step_rate::unsigned-little-16, rest::binary>>,
        %{flags: [{:avg_step_rate, true} | remaining_flags]} = context
      ) do
    parse(rest, %{
      context
      | flags: remaining_flags,
        fields: Map.put(context[:fields], :avg_step_rate, avg_step_rate)
    })
  end

  def parse(
        <<positive_elevation_gain::unsigned-little-16, rest::binary>>,
        %{flags: [{:elevation_gain, true} | remaining_flags]} = context
      ) do
    # 0.1 meters but weird
    # * 0.1
    elevation_gain = positive_elevation_gain

    parse(rest, %{
      context
      | flags: remaining_flags,
        fields: Map.put(context[:fields], :elevation_gain, elevation_gain)
    })
  end

  def parse(
        <<stride_count::unsigned-little-16, rest::binary>>,
        %{flags: [{:stride_count, true} | remaining_flags]} = context
      ) do
    parse(rest, %{
      context
      | flags: remaining_flags,
        fields: Map.put(context[:fields], :stride_count, stride_count)
    })
  end

  def parse(
        <<total_energy::unsigned-little-16, energy_per_hour::unsigned-little-16,
          energy_per_minute::unsigned-little-8, rest::binary>>,
        %{flags: [{:expended_energy, true} | remaining_flags]} = context
      ) do
    total_energy = if total_energy == 0xFFFF, do: :data_not_available, else: total_energy
    energy_per_hour = if energy_per_hour == 0xFFFF, do: :data_not_available, else: energy_per_hour

    energy_per_minute =
      if energy_per_minute == 0xFF, do: :data_not_available, else: energy_per_minute

    parse(rest, %{
      context
      | flags: remaining_flags,
        fields:
          context[:fields]
          |> Map.put(:total_energy, total_energy)
          |> Map.put(:energy_per_hour, energy_per_hour)
          |> Map.put(:energy_per_minute, energy_per_minute)
    })
  end

  def parse(
        <<hr::unsigned-little-8, rest::binary>>,
        %{flags: [{:hr, true} | remaining_flags]} = context
      ) do
    parse(rest, %{context | flags: remaining_flags, fields: Map.put(context[:fields], :hr, hr)})
  end

  def parse(
        <<met::unsigned-little-8, rest::binary>>,
        %{flags: [{:met, true} | remaining_flags]} = context
      ) do
    met = met * 0.1
    parse(rest, %{context | flags: remaining_flags, fields: Map.put(context[:fields], :met, met)})
  end

  def parse(
        <<elapsed_time::unsigned-little-16, rest::binary>>,
        %{flags: [{:elapsed_time, true} | remaining_flags]} = context
      ) do
    parse(rest, %{
      context
      | flags: remaining_flags,
        fields: Map.put(context[:fields], :elapsed_time, elapsed_time)
    })
  end

  def parse(
        <<remaining_time::unsigned-little-16, rest::binary>>,
        %{flags: [{:remaining_time, true} | remaining_flags]} = context
      ) do
    parse(rest, %{
      context
      | flags: remaining_flags,
        fields: Map.put(context[:fields], :remaining_time, remaining_time)
    })
  end

  def parse(<<rest::binary>>, %{flags: [{_, false} | remaining_flags]} = context) do
    parse(rest, Map.put(context, :flags, remaining_flags))
  end

  # nothing left to parse, no remaining flags - mission success
  def parse(<<>>, %{flags: [], fields: %{more_data: false} = fields} = _context) do
    {:ok, fields}
  end

  def parse(<<>>, %{flags: [_ | _], fields: %{more_data: false} = _fields} = _context) do
    {:error, :end_reached_prematurely}
  end

  def parse(<<>>, %{flags: remaining_flags, fields: %{more_data: true} = fields} = _context) do
    # more data is true, expecting a followup packet
    dbg(remaining_flags)
    {:ok, fields}
  end

  def parse(rest, context) do
    [rest, context]
  end
end

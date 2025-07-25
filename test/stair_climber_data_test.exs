defmodule StairClimberDataTest do
  use ExUnit.Case
  use ExUnitProperties

  alias ExFTMS.StairClimberData

  doctest ExFTMS.StairClimberData
  @base16 "FE01 0D00 1B00 2A00 2A00 3101 2C00 1701 FFFF 233C 01"

  test "decode/1 succeeds on data without followups" do
    input =
      @base16
      |> String.replace(" ", "")
      |> Base.decode16!()

    assert {:ok,
            %{
              elapsed_time: 316,
              met: 3.5,
              hr: 255,
              energy_per_minute: :data_not_available,
              energy_per_hour: 279,
              total_energy: 44,
              stride_count: 305,
              elevation_gain: 42,
              avg_step_rate: 42,
              spm: 27,
              floors: 13
            }} =
             StairClimberData.decode(input)
  end

  test "decode!/1 succeeds on data without followups" do
    input =
      @base16
      |> String.replace(" ", "")
      |> Base.decode16!()

    assert %{floors: 13} =
             StairClimberData.decode!(input)
  end

  test "decode!/1 raises on a too short input" do
    input =
      "FE01 0D00 1B00 2A00 2A00 3101"
      |> String.replace(" ", "")
      |> Base.decode16!()

    assert_raise ArgumentError, fn -> StairClimberData.decode!(input) end
  end

  test "encode/1 succeeds on data without followups" do
    assert String.replace(@base16, " ", "") ==
             %StairClimberData{
               elapsed_time: 316,
               met: 3.5,
               hr: 255,
               energy_per_minute: :data_not_available,
               energy_per_hour: 279,
               total_energy: 44,
               stride_count: 305,
               elevation_gain: 42,
               avg_step_rate: 42,
               spm: 27,
               floors: 13
             }
             |> StairClimberData.encode(24)
             |> List.first()
             |> Base.encode16()
  end

  defp data_not_available(8, 255) do
    :data_not_available
  end

  defp data_not_available(16, 65_535) do
    :data_not_available
  end

  defp data_not_available(_, n), do: n

  defp valid_data_generator do
    gen all(
          floors <- StreamData.integer(0..65_535),
          spm <- StreamData.integer(0..65_535),
          avg_step_rate <- StreamData.integer(0..65_535),
          elevation_gain <- StreamData.integer(0..65_535),
          stride_count <- StreamData.integer(0..65_535),
          total_energy <- StreamData.integer(0..65_535),
          energy_per_hour <- StreamData.integer(0..65_535),
          energy_per_minute <- StreamData.integer(0..255),
          hr <- StreamData.integer(0..255),
          met <- StreamData.integer(0..255),
          elapsed_time <- StreamData.integer(0..65_535)
        ) do
      %{
        floors: floors,
        spm: spm,
        avg_step_rate: avg_step_rate,
        elevation_gain: elevation_gain,
        stride_count: stride_count,
        total_energy: data_not_available(16, total_energy),
        energy_per_hour: data_not_available(16, energy_per_hour),
        energy_per_minute: data_not_available(8, energy_per_minute),
        hr: hr,
        met: met * 0.1,
        elapsed_time: elapsed_time,
        remaining_time: nil
      }
    end
  end

  property "returns false for other times" do
    check all(stair_climber_data <- valid_data_generator()) do
      [encoded] = StairClimberData.encode(struct(StairClimberData, stair_climber_data), 99)

      {:ok, decoded} = StairClimberData.decode(encoded)

      assert stair_climber_data.floors == decoded.floors
      assert stair_climber_data.spm == decoded.spm
      assert stair_climber_data.avg_step_rate == decoded.avg_step_rate
      assert stair_climber_data.elevation_gain == decoded.elevation_gain
      assert stair_climber_data.stride_count == decoded.stride_count
      assert stair_climber_data.total_energy == decoded.total_energy
      assert stair_climber_data.energy_per_hour == decoded.energy_per_hour
      assert stair_climber_data.energy_per_minute == decoded.energy_per_minute
      assert stair_climber_data.hr == decoded.hr
      assert stair_climber_data.met == decoded.met
      assert stair_climber_data.elapsed_time == decoded.elapsed_time

      if stair_climber_data.remaining_time != nil do
        assert stair_climber_data.remaining_time == decoded.remaining_time
      end
    end
  end
end

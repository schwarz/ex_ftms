defmodule StairClimberDataEncoderTest do
  use ExUnit.Case

  alias ExFTMS.StairClimberData.Encoder

  doctest Encoder

  test "build_flags/?" do
    build_order = [
      floors: 2,
      spm: 2,
      avg_step_rate: 2,
      elevation_gain: 2,
      stride_count: 2,
      energy_expenditure: 5,
      hr: 1,
      met: 1,
      elapsed_time: 2
    ]

    assert "FE01" == Base.encode16(Encoder.build_flags(build_order))
  end

  test "ensure missing MET is encoded correctly" do
    assert "00020D000100" ==
             %ExFTMS.StairClimberData{floors: 13, remaining_time: 1}
             |> Encoder.encode()
             |> List.first()
             |> Base.encode16()
  end
end

defmodule ExFTMS.StairClimberData do
  @moduledoc """
  Documentation for `StairClimberData`.
  """

  alias ExFTMS.StairClimberData

  defstruct floors: nil,
            spm: nil,
            avg_step_rate: nil,
            elevation_gain: nil,
            stride_count: nil,
            total_energy: nil,
            energy_per_hour: nil,
            energy_per_minute: nil,
            hr: nil,
            met: nil,
            elapsed_time: nil,
            remaining_time: nil

  @doc """
  Decodes the input binary of stair climber data into a `StairClimberData` struct.
  Returns `{:ok, data}` if parsing is successful, or `:error` if parsing fails.

  If you have a Base16 encoded string (hex values from e.g. nRF Connect) then use `Base.decode16/1` first.
  """
  def decode(binary, previous_data \\ %{}) when is_binary(binary) do
    case StairClimberData.Decoder.parse(binary) do
      {:ok, fields} ->
        {:ok, Map.merge(previous_data, fields)}

      {:error, _reason} ->
        :error
    end
  end

  @doc """
  Same as `decode/1`, but returns the data directly,
  or raises a `ParseError` exception if there is bad input data.
  """
  def decode!(binary, previous_data \\ %{}) when is_binary(binary) do
    case decode(binary, previous_data) do
      {:ok, fields} -> fields
      :error -> raise(ArgumentError, Base.encode16(binary))
    end
  end

  @doc """
  Encodes a `%StairClimberData{}` into a list of binary notifications, length 1 or more.
  Send the list in the order of head first, the final binary will have the more data flag set to 0.

  See `4.19 Transmission of a Data Record` in the FTMS spec.
  """
  def encode(%ExFTMS.StairClimberData{} = map, mtu_size \\ 23) do
    StairClimberData.Encoder.encode(map, mtu_size - 3)
  end
end

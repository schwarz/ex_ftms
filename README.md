[![Hex pm](https://img.shields.io/hexpm/v/ex_ftms.svg?style=flat)](https://hex.pm/packages/ex_ftms)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_ftms/)

# ExFTMS

Helps you decode and encode [Bluetooth FTMS](https://www.bluetooth.com/specifications/specs/fitness-machine-service-1-0/) packets in Elixir.

The implementation is intentionally kept simple and straightforward to help fellow [grugs](https://grugbrain.dev) understand and compare it to the spec.

## Installation

Add `ex_ftms` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_ftms, "~> 0.1.0"}
  ]
end
```

Full documentation can be found at <https://hexdocs.pm/ex_ftms>.

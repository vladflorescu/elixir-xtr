import Logger

defmodule Xtr.CLI do
  @commands [
    {:run, "Run a new command."},
    {:run_previous, "Run a previous command."},
    {:exit, "Close connection."}
  ]

  def init do
    %{inside: :default, command_history: []}
  end

  def get_current_description(%{inside: :default}) do
    """
    Select an action: \r\n#{
      @commands
      |> Enum.with_index()
      |> Enum.map_join("\r\n", fn ({{_, text}, index}) -> "#{index + 1}. #{text}" end)
    }
    """
    |> String.trim
  end

  def get_current_description(%{inside: level}) do
    case level do
      :run ->
        "Type your command:"
      _ ->
        raise "Invalid `inside` value."
    end
  end

  def invoke(%{inside: :default} = state, command) do
    command
    |> Integer.parse()
    |> (fn ({number, _}) -> Enum.at(@commands, number - 1) end).()
    |> (fn ({command, _}) -> %{state | inside: command} end).()
  end
end
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
      :run -> "Type your command:"
      _ -> raise "Invalid `inside` value."
    end
  end

  def invoke(%{inside: :default} = state, command_str) do
    {command_id, _} = command_str
    |> Integer.parse()
    |> (fn ({number, _}) -> Enum.at(@commands, number - 1) end).()

    if command_id == :exit do
      :exit |> with_feedback(nil)
    else
      %{state | inside: command_id} |> with_feedback(nil)
    end
  end

  def invoke(%{inside: :run} = state, command) do
  end

  defp with_feedback(x, msg) do
    {x, msg}
  end
end
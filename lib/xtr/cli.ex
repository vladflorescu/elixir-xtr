import Logger

defmodule Xtr.CLI do
  @history_max_size 10
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
      :run_previous -> "Type the number of the command you want to run:"
      _ -> raise "Invalid `inside` value."
    end
  end

  def invoke(state, ":back") do
    %{state | inside: :default} |> with_feedback(nil);
  end

  def invoke(%{inside: :default} = state, str) do
    {command_id, _} = str
    |> Integer.parse()
    |> (fn ({number, _}) -> Enum.at(@commands, number - 1) end).()

    case command_id do
      :run ->
        %{state | inside: command_id} |> with_feedback(nil)
      :run_previous ->
        if Enum.empty?(Map.get(state, :command_history)) do
          state |> with_feedback("No commands available.")
        else
          %{state | inside: command_id} |> with_formatted_command_history
        end
      _ ->
        :exit |> with_feedback(nil)
    end
  end

  def invoke(%{inside: :run} = state, str) do
    {status, feedback} = try do
      {:ok, Xtr.Command.exec(str)}
    rescue
      err in Xtr.Command.InvalidCommandError -> {:error, err.message}
      err in Xtr.Command.InvalidFilterError -> {:error, err.message}
    end

    %{state | inside: :default}
    |> maybe_update_history(status, str)
    |> with_feedback(feedback)
  end

  def invoke(%{inside: :run_previous} = state, str) do
    command_history = Map.get(state, :command_history)

    case Integer.parse(str) do
      :error ->
        %{state | inside: :default} |> with_feedback("Couldn't parse the input.")
      {command_number, _} ->
        if command_number > 0 && command_number <= Enum.count(command_history) do
          invoke(%{state | inside: :run}, Enum.at(command_history, command_number - 1))
        else
          %{state | inside: :default} |> with_feedback("Invalid number.")
        end
    end
  end

  defp maybe_update_history(state, command_status, command_str) do
    if command_status == :error do
      state
    else
      [command_str | Map.get(state, :command_history)]
      |> Enum.uniq
      |> Enum.take(@history_max_size)
      |> (fn hist -> Map.put(state, :command_history, hist) end).()
    end
  end

  defp with_feedback(x, msg) do
    {x, msg}
  end

  defp with_formatted_command_history(state) do
    str = Map.get(state, :command_history)
    |> Enum.with_index()
    |> Enum.map_join("\r\n", fn {command_str, index} ->
      "#{index + 1}. #{command_str}"
    end)
    |> (&("\r\nThe last commands are:\r\n" <> &1)).()

    {state, str}
  end
end
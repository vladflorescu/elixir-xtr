require Logger

defmodule Xtr.Command do
  defmodule InvalidCommandError do
    defexception [:message]

    def exception(value) do
      %InvalidCommandError{message: "Invalid command: #{value}."}
    end
  end

  @doc """
    Example
    Xtr.Command.exec("query fmi | sort-by stargazers_count:desc | limit 5 | only name")
  """
  def exec(str) do
    [command | options] = str |> String.split("|") |> Enum.map(&String.trim/1)
    [command_name, command_val] = command |> String.split(~r/\s+/)

    try do
      run_command({command_name, command_val, options})
    rescue
      FunctionClauseError -> raise InvalidCommandError, command_name
    end
  end

  defp run_command({"query", val, options}) do
    Enum.join(options, " ")
  end
end
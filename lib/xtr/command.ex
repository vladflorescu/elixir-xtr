require Logger

defmodule Xtr.Command do
  defmodule InvalidCommandError do
    defexception [:message]

    def exception(value) do
      %InvalidCommandError{message: "Invalid command: #{value}."}
    end
  end

  defmodule InvalidFilterError do
    defexception [:message]

    def exception(value) do
      %InvalidFilterError{message: "Invalid filter: #{value}."}
    end
  end

  @doc """
    Example
    Xtr.Command.exec("query fmi | sort-by stargazers_count:desc | limit 5 | only name stars")
  """
  def exec(str) do
    [command | options_strs] = str |> String.split("|") |> Enum.map(&String.trim/1)
    [command_name | command_val] = command |> String.split(~r/\s+/)

    # try do
      options = Enum.map(options_strs, fn str ->
        [name | values] = String.split(str, " ")
        {name, values}
      end)

      run_command(command_name, command_val, options)
    # rescue
    #   FunctionClauseError -> raise InvalidCommandError, command_name
    # end
  end

  defp run_command("fetch", val, options) do
    Xtr.Command.Fetch.run(val, options)
  end

  @doc """
  val = ["fmi", "gentlab"] (un array de nume de fisiere de pe disk)
  options = [{"sort-by", ["stargazers_count:desc"]}, {"limit", ["5"]}, "only": ["name"]}]
  """
  defp run_command("query", dirs, options) do
    Xtr.Command.Query.run(dirs, options);
  end
end

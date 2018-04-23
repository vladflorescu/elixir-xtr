require IEx
require Logger

#for c <- ["a", "b", "c", "d"], do: Task.start_link fn -> File.open("data/hello", [:write]) |> elem(1) |> (fn file -> (for i <- 1..500000, do: c) |> Enum.join("") |> (fn str -> IO.binwrite(file, str) end).() end).() |> Logger.info end
defmodule Xtr.Command.Fetch do
  @doc"""
    ## Examples
    iex> fetch vsilviu vladflorescu94 | into fmi altceva
  """
  def run(usernames, [{"into", group_names}]) do
    data = usernames
    |> Enum.uniq
    |> Task.async_stream(fn(username) ->
      case HTTPoison.get("https://api.github.com/users/#{username}/repos") do
        {:error, err} -> {username, :error}
        {:ok, %{status_code: 404}} -> {username, :not_found}
        {:ok, resp} -> {username, Map.get(resp, :body)}
      end
    end)

    error_messages = data
    |> Enum.map((fn {:ok, datum} -> get_error_message(datum) end))
    |> Enum.reject(&is_nil/1)

    if Enum.count(error_messages) > 0 do
      Enum.join(error_messages, "\r\n")
    else
      write_data_to_disk(data, group_names)
      "Data successfully fetched and saved."
    end
  end

  defp get_error_message({username, resp}) do
    case resp do
      :error -> "Got error when fetching repos for #{username}."
      :not_found -> "No username named #{username} found."
      _ -> nil
    end
  end

  defp write_data_to_disk(data, group_names) do
    Enum.reduce(data, "", fn({:ok, {username, json}}, _acc) ->
      Enum.each(group_names, fn group_name ->
        dirpath = Path.join("data", group_name)
        if (!File.dir?(dirpath)), do: File.mkdir(dirpath)
        {:ok, file} = File.open(Path.join(dirpath, "#{username}.json"), [:write])
        Logger.info("Saved new file: #{(Path.join(dirpath, "#{username}.json"))}")
        IO.binwrite(file, json)
      end)
    end)
  end
end

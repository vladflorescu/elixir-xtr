require Logger

defmodule Xtr.Command.Fetch do
  #for c <- ["a", "b", "c", "d"], do: Task.start_link fn -> File.open("data/hello", [:write]) |> elem(1) |> (fn file -> (for i <- 1..500000, do: c) |> Enum.join("") |> (fn str -> IO.binwrite(file, str) end).() end).() |> Logger.info end
  def run(usernames, [{"into", group_names}]) do
    # fetch vsilviu vladflorescu94 | into fmi altceva
    stream = Task.async_stream(usernames, fn(username) ->
      HTTPoison.get("https://api.github.com/users/#{username}/repos")
      |> (fn {:ok, resp} -> Map.get(resp, :body) end).()
      |> (fn json -> {username, json} end).()
    end)

    Enum.reduce(stream, "", fn({:ok, {username, json}}, _acc) ->
      Enum.each(group_names, fn group_name ->
        dirpath = Path.join("data", group_name)
        if (!File.dir?(dirpath)), do: File.mkdir(dirpath)
        {:ok, file} = File.open(Path.join(dirpath, "#{username}.json"), [:write])
        Logger.info((Path.join(dirpath, "#{username}.json")))
        IO.binwrite(file, json)
      end)
    end)

    "Data successfully fetched"
  end
end
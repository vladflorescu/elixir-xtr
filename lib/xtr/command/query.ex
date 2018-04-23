require Logger
require File
require Path

defmodule Xtr.Command.Query do

  @doc """
    dirs = ["gentlab", "fmi"]
    options = [{"sort" : []}, {"only": []}]
  """
  def run(dirs, options) do

    #load files from dirs into array
    files = dirs
      |> Enum.map(&Path.wildcard("./data/#{&1}/*.json"))
      |> Enum.map(&File.read!(&1))
      |> Enum.map(&Poison.decode!(~s(#{&1})))
      |> List.flatten;

    #apply filters on files
    IO.puts "Options = #{inspect options}";
    updatedFiles = Enum.reduce(options, files, fn({filter, values}, acc) -> applyFilter(filter, values, acc) end);

    "#{inspect updatedFiles}";
  end

  defp applyFilter("sort-by", filters, files) do
    Enum.reduce(filters, files, fn(filter, acc) -> Enum.sort_by(acc, fn mapp -> mapp[filter] end) end);
  end

  defp applyFilter("only", filters, files) do
    Enum.map(
      files,
      fn file ->
        Enum.reduce(
          file,
          %{},
          fn ({key, value}, acc) ->
            if(Enum.member?(filters, key)) do
              Map.put(acc, key, value)
            else
              acc
            end
          end)
      end);
  end

  defp applyFilter("limit", [count | tail], files) do
    Enum.take(files, elem(Integer.parse(count), 0));
  end

  defp applyFilter(invalidFilter, values, acc) do
    raise Xtr.Command.InvalidFilterError, invalidFilter;
  end

end
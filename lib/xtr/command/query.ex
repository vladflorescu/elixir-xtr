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
      |> Enum.join;

    #apply options to array
#    Enum.reduce([{"sort-by", ["1, 2"]}, {"only", ["3", "4"]}], "", fn ({filter, vals}, acc) -> Enum.join([filter, acc], ",") end)
    Enum.reduce(options, files, fn({filter, values}, acc) -> applyOption(filter, values, acc) end);
  end

  defp applyOption("sort-by", values, acc) do
    Logger.info("In sort-by method");
    acc
  end

  defp applyOption("only", values, acc) do
    Logger.info("In only method");
    acc
  end

  defp applyOption("limit", values, acc) do
    Logger.info("In limit method!")
    acc
  end

  defp applyOption(invalidFilter, values, acc) do
    raise Xtr.Command.InvalidFilterError, invalidFilter;
  end

end
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
    Logger.info("Calculated this : #{files}");
    files;
  end

end
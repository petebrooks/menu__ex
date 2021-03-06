defmodule Menu.CLI do
  alias Menu.Parser
  alias Menu.Solver

  def main(argv) do
    argv
      |> parse_args
      |> process
  end

  def process(:help) do
    IO.puts "usage: menu <path/to/menu>"
  end

  def process(filepath) do
    Parser.parse(filepath)
      |> Solver.solve
      |> print_result
  end

  def print_result(result) do
    Enum.each result, fn(list) ->
      IO.puts "Combination:"
      Enum.each format(list), &IO.puts/1
    end
  end

  @doc """
  Groups items by number of times the item appears in the combination.
  Used for formatting.

  ## Examples

      iex> list = [%Menu.Item{name: "french fries"}]
      iex> Menu.CLI.format(list)
      ["    1 french fries"]
  """
  def format(list) do
    Enum.map group(list), fn{k, [v | _]} ->
      "    #{k} #{v.name}"
    end
  end

  @doc """
  Groups items by number of times the item appears in the combination.
  Used for formatting.

  ## Examples

      iex> list = ["one", "two", "two", "three", "three", "three"]
      iex> Menu.CLI.group(list)
      %{1 => ["one"], 2 => ["two", "two"], 3 => ["three", "three", "three"]}
  """
  def group(list) do
    Enum.group_by(list, &(count_occurrences(list, &1)))
  end

  def count_occurrences(list, item) do
    Enum.filter(list, &(&1 == item)) |> Enum.count
  end

  def parse_args(argv) do
    args = OptionParser.parse(argv, switches: [help: :boolean],
                                    aliases:  [h: :help])
    case args do
      { [help: true], _, _ } -> :help
      { _, [""], _ }         -> :help
      { _, [filepath], _ }   -> filepath
    end
  end
end

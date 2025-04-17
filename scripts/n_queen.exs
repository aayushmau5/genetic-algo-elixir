defmodule NQueen do
  @moduledoc """
  The N-queen problem.
  Given N queens in a NxN chess board, find the correct position of N queens in the chess board so that they don't threaten each other
  """

  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    # permutation genotype
    genes = Enum.shuffle(0..7)
    %Chromosome{genes: genes, size: 8}
  end

  @impl true
  def fitness_function(%Chromosome{} = chromosome) do
    # the number of non-conflicts
    diag_clashes =
      for i <- 0..7, j <- 0..7 do
        if i != j do
          dx = abs(i - j)

          dy =
            abs(
              chromosome.genes
              |> Enum.at(i)
              |> Kernel.-(Enum.at(chromosome.genes, j))
            )

          if dx == dy, do: 1, else: 0
        else
          0
        end
      end

    length(Enum.uniq(chromosome.genes)) - Enum.sum(diag_clashes)
  end

  @impl true
  def terminate?(population, _generation) do
    Enum.max_by(population, &fitness_function/1).fitness == 8
  end
end

soln = Genetic.run(NQueen)

IO.write("\n")
IO.inspect(soln)

defmodule OneMax do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    genes = for _ <- 1..10000, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 10000}
  end

  @impl true
  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  @impl true
  def terminate?([best | _]), do: best.fitness == 10000
end

soln = Genetic.run(OneMax)

IO.write("\n")
IO.inspect(soln)

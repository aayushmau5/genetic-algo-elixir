defmodule Toolbox.Selection do
  @doc """
  Selects the first n from the **sorted** population

  doesn't factor in genetic diversity. prone to premature convergence
  """
  def elite(population, n) do
    Enum.take(population, n)
  end

  @doc """
  selects chromosomes randomly(doesn't depend on fitness of a chromosome). better genetic diversity
  """
  def random(population, n) do
    Enum.take_random(population, n)
  end

  @doc """
  Tournament selection

  Selecting n chromosomes from population, and then selecting a winner out of them.

  Choosing parents that's both diverse and strong. Might not be suitable for small population.
  """
  def tournament() do
  end

  @doc """
  *fitness-proportionate selection*

  Choosing parents with a probablity proportional to their fitness(roulette wheel)

  Slow and kinda complex to implement.
  """
  def roulette() do
  end
end

defmodule Toolbox.Reinsertion do
  @moduledoc """
  Reinsertion to create new population

  Reinseration: population length can be variable
  Replacement: working with same population length
  """

  def pure(_parents, offspring, _leftovers) do
    # every old population is replaced with an offspring of the new population
    # generational replacement
    offspring
  end

  def elitist(parents, offspring, leftovers, survival_rate) do
    # keeping the top-n of old population to survive to the next generation
    # surival rate
    old = parents ++ leftovers
    n = floor(length(old) * survival_rate)

    survivors =
      old
      |> Enum.sort_by(& &1.fitness, &>=/2)
      |> Enum.take(n)

    offspring ++ survivors
  end

  def uniform(parents, offspring, leftovers, survival_rate) do
    # Uniform reinsertion selects random chromosomes from the old population to survive to the next generation
    old = parents ++ leftovers
    n = floor(length(old) * survival_rate)

    survivors = Enum.take_random(old, n)
    offspring ++ survivors
  end
end

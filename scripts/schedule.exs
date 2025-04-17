defmodule Schedule do
  @moduledoc """
  Given classes along with their credits, difficulty, usefulness and personal interest, creating a class schedule keeping in mind the credit-hour limitation

  It's a constrained optimization problem

  Multi-objective: Maximizing interest and usefulness while minimizing difficulty + 18 credit-hours
  """

  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    # the schedule is represented in the form of binary genotype
    genes = for _ <- 1..10, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 10}
  end

  @impl true
  def fitness_function(%Chromosome{} = chromosome) do
    schedule = chromosome.genes

    credit =
      schedule
      |> Enum.zip(credit_hours())
      |> Enum.map(fn {class, credits} -> class * credits end)
      |> Enum.sum()

    # penalty is applied when crossing the credit-hour constrain
    if credit > 18.0 do
      -99999
    else
      # fitness
      [schedule, difficulties(), usefulness(), interest()]
      |> Enum.zip()
      |> Enum.map(fn {class, diff, use, int} ->
        # each criteria is given a weight of 33% or 0.3
        class * (0.3 * use + 0.3 * int - 0.3 * diff)
      end)
      |> Enum.sum()
    end
  end

  @impl true
  def terminate?(_population, generation), do: generation == 1000

  defp credit_hours, do: [3.0, 3.0, 3.0, 4.5, 3.0, 3.0, 3.0, 3.0, 4.5, 1.5]
  defp difficulties, do: [8.0, 9.0, 4.0, 3.0, 5.0, 2.0, 4.0, 2.0, 6.0, 1.0]
  defp usefulness, do: [8.0, 9.0, 6.0, 2.0, 8.0, 9.0, 1.0, 2.0, 5.0, 1.0]
  defp interest, do: [8.0, 8.0, 5.0, 9.0, 7.0, 2.0, 8.0, 2.0, 7.0, 10.0]
end

soln =
  Genetic.run(Schedule,
    reinsertion_strategy: &Toolbox.Reinsertion.elitist(&1, &2, &3, 0.1),
    selection_rate: 0.8,
    mutation_rate: 0.1
  )

IO.write("\n")
IO.inspect(soln)

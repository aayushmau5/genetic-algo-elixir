defmodule Genetic do
  @moduledoc """
  The genetic algorithm framework

  Genetic algorithms are well-suited for combinatorial optimization problem

  *constrained optimization*
  *exploration and exploitation*
  *multi objectives*

  population: parents, children, leftovers

  process: selection, crossover, mutation

  reinsertion or replacement: the process of combining the byproducts of selection, crossover and mutation into a new population
  """

  alias Types.Chromosome

  def run(problem, opts \\ []) do
    # initalize a population
    population = initialize(&problem.genotype/0)

    population
    |> evolve(problem, 0, opts)
  end

  def evolve(population, problem, generation, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)

    # keep track of stats
    statistics(population, generation, opts)

    # get the first population and show it's fitness
    best = hd(population)
    fit_str = best.fitness |> :erlang.float_to_binary(decimals: 4)

    IO.write("\rCurrent Best: #{fit_str}\tGeneration: #{generation}")

    if problem.terminate?(population, generation) do
      # if the termination condition is met, exit
      best
    else
      # else go through the evoluation
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      mutants = mutation(population, opts)
      offspring = children ++ mutants
      new_population = reinsertion(parents, offspring, leftover, opts)

      evolve(new_population, problem, generation + 1, opts)
    end
  end

  @doc """
  A list of chromosomes called "population".
  The problem at hand decideds the encoding of the genes in chromosomes
  """
  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end

  @doc """
  Evaluate the popluation based on the fitness function and return the result sorted on fitness of each chromosome
  """
  def evaluate(population, fitness_function, opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(& &1.fitness, &>=/2)
  end

  @doc """
  Select the "best" choromosome from the population. the "best" depends on the problem at hand.
  We have "selection_type" which is an algorithm that's responsible for getting the "best" chromosomes(called parents) for reproduction(to create children)
  """
  def select(population, opts \\ []) do
    select_fn = Keyword.get(opts, :selection_type, &Toolbox.Selection.elite/2)
    select_rate = Keyword.get(opts, :selection_rate, 0.8)

    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n + 1

    parents =
      select_fn
      |> apply([population, n])

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))

    {parents, MapSet.to_list(leftover)}
  end

  @doc """
  randomly creates genes from parent genes to create children genes using different crossover algorithms
  """
  def crossover(population, opts \\ []) do
    crossover_fn = Keyword.get(opts, :crossover_type, &Toolbox.Crossover.order_one_crossover/2)

    Enum.reduce(population, [], fn {p1, p2}, acc ->
      {c1, c2} = apply(crossover_fn, [p1, p2])
      [c1, c2 | acc]
    end)
  end

  @doc """
  Mutation the population introuding diversity for better solution
  Helps with genetic diversity.

  Prevents "premature convergence"
  """
  def mutation(population, opts \\ []) do
    mutate_fn = Keyword.get(opts, :mutation_type, &Toolbox.Mutation.scramble/1)
    rate = Keyword.get(opts, :mutation_rate, 0.05)
    n = floor(length(population) * rate)

    population
    |> Enum.take_random(n)
    |> Enum.map(&apply(mutate_fn, [&1]))
  end

  @doc """
  Reinsertion to create a new population using different reinsertion strategy
  """
  def reinsertion(parents, offspring, leftover, opts \\ []) do
    strategy = Keyword.get(opts, :reinsertion_strategy, &Toolbox.Reinsertion.pure/3)
    apply(strategy, [parents, offspring, leftover])
  end

  def statistics(population, generation, opts \\ []) do
    # keep track of stats such as fitness, generation, etc. using ets table(handled by a genserver)
    default_stats = [
      min_fitness: &Enum.min_by(&1, fn c -> c.fitness end).fitness,
      max_fitness: &Enum.max_by(&1, fn c -> c.fitness end).fitness,
      mean_fitness: &Enum.sum(Enum.map(&1, fn c -> c.fitness end))
    ]

    stats = Keyword.get(opts, :statistics, default_stats)

    stats_map =
      stats
      |> Enum.reduce(%{}, fn {key, func}, acc ->
        Map.put(acc, key, func.(population))
      end)

    Utilities.Statistics.insert(generation, stats_map)
  end
end

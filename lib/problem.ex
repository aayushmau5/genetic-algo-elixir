defmodule Problem do
  # Problem consists of behaviours that each problem statement should implement
  alias Types.Chromosome

  # how to encode your problem and create a chromosome
  @callback genotype :: Chromosome.t()

  # the fitness function. depends on the problem to choose the optimal chromosomes
  @callback fitness_function(Chromosome.t()) :: number()

  # when to terminate the algorithm
  @callback terminate?(Enum.t(Chromosome.t()), integer()) :: boolean()
end

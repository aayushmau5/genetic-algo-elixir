defmodule Toolbox.Mutation do
  @moduledoc """
  Mutates the genes to maintain genetic diversity or introduce randomness to the genes in order to find solutions.

  Sometimes selection and crossover might not be enough, that's where mutation comes in.
  """
  alias Types.Chromosome

  def flip(chromosome, p \\ 0.5) do
    # bit flip mutation. only for binary genotypes
    genes =
      Enum.map(chromosome.genes, &if(:rand.uniform() < p, do: Bitwise.bxor(&1, 1), else: &1))

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def scramble(chromosome) do
    # scramble the genes
    genes = Enum.shuffle(chromosome.genes)
    %Chromosome{genes: genes, size: chromosome.size}
  end
end

defmodule Codebreaker do
  @moduledoc """
  Determining 64-bit key in order to decrypt an encrypted piece of data that's been encoded using (DATA XOR 64-bit key)

  decrypted data(known) = encrypted data(known) XOR 64-bit key(unknown)
  """

  @behaviour Problem
  alias Types.Chromosome
  import Bitwise

  @impl true
  def genotype() do
    genes = for _ <- 1..64, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 64}
  end

  @impl true
  def fitness_function(chromosome) do
    target = ~c"ILoveGeneticAlgorithms"
    encrypted = ~c"LIjs`B`k`qlfDibjwlqmhv"
    cipher = fn word, key -> Enum.map(word, &rem(bxor(&1, key), 32768)) end

    key =
      chromosome.genes
      |> Enum.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = List.to_string(cipher.(encrypted, key))
    String.jaro_distance(to_string(target), guess)
  end

  @impl true
  def terminate?(population, _generation) do
    Enum.max_by(population, &fitness_function/1).fitness == 1
  end
end

soln =
  Genetic.run(
    Codebreaker,
    crossover_type: &Toolbox.Crossover.single_point/2
  )

{key, ""} =
  soln.genes
  |> Enum.map(&Integer.to_string(&1))
  |> Enum.join("")
  |> Integer.parse(2)

IO.write("\nThe Key is #{key}\n")

defmodule Types.Chromosome do
  # a chromosome consists of a set of genes, the fitness of chromosome and it's age
  # genes are how you encode your solution
  # genes are encoded in -> binary, permutation(combinatorial optimization), real-value, tree-based
  @type t :: %__MODULE__{
          genes: Enum.t(),
          size: integer(),
          fitness: number(),
          age: integer()
        }

  @enforce_keys :genes
  defstruct [:genes, size: 0, fitness: 0, age: 0]
end

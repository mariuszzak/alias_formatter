defmodule AliasFormatter.CompilationTracer.Server do
  @moduledoc false

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec record(any, any, any, any, any, any) :: :ok
  def record(module_name, module_file, _module_line, alias_line, aliased_module, alias_as) do
    Agent.update(__MODULE__, fn state ->
      update_state(state, module_file, module_name, alias_line, aliased_module, alias_as)
    end)
  end

  defp update_state(state, module_file, module_name, alias_line, aliased_module, alias_as) do
    state
    |> Map.put_new(module_file, %{})
    |> Map.update!(module_file, fn file_state ->
      file_state
      |> Map.put_new(module_name, [])
      |> Map.update!(module_name, fn module_aliases ->
        new_alias = %{line: alias_line, module: aliased_module, as: alias_as}

        [new_alias | module_aliases]
      end)
    end)
  end

  def entries(file_path) do
    Agent.get(__MODULE__, &Map.get(&1, file_path, %{}))
  end
end

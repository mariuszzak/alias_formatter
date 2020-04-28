defmodule AliasFormatter.CompilationTracer do
  @moduledoc false

  alias AliasFormatter.CompilationTracer.Server

  def trace(
        {:alias, [line: alias_line], aliased_module, alias_as, _opts},
        %{file: module_file, line: module_line, module: module_name}
      ) do
    Server.record(
      module_name,
      module_file,
      module_line,
      alias_line,
      aliased_module,
      alias_as
    )

    :ok
  end

  def trace(_, _) do
    :ok
  end
end

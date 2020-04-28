defmodule AliasFormatter do
  @moduledoc false

  alias AliasFormatter.CompilationTracer

  def format_code(source_code) do
    {:ok, _} = CompilationTracer.Server.start_link()
    Code.compiler_options(tracers: [CompilationTracer], parser_options: [])
    Code.compile_string(source_code, "nofile")
    entries = CompilationTracer.Server.entries("nofile")

    format_aliases(source_code, entries)
  end

  defp format_aliases(source_code, entries) do
    source_code_lines =
      source_code
      |> String.split("\n")

    Enum.reduce(entries, source_code_lines, &apply_entry/2)
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp apply_entry({_module, aliases}, source_code_lines) do
    aliases
    |> reorganize_aliases()
    |> replace_aliases(source_code_lines)
  end

  defp reorganize_aliases(aliases) do
    first_alias_line =
      aliases
      |> Enum.min_by(& &1.line)
      |> Map.get(:line)

    aliases
    |> Enum.sort(fn left, right ->
      cond do
        alias_with_as?(left) and alias_with_as?(right) ->
          module_name_for_comparison(left.module) <= module_name_for_comparison(right.module)

        alias_with_as?(left) and !alias_with_as?(right) ->
          false

        !alias_with_as?(left) and alias_with_as?(right) ->
          true

        true ->
          module_name_for_comparison(left.module) <= module_name_for_comparison(right.module)
      end
    end)
    |> Enum.with_index(first_alias_line)
    |> Enum.map(fn {a, line} -> %{a | line: line} end)
  end

  defp module_name_for_comparison(module) do
    module
    |> Macro.to_string()
    |> String.downcase()
    |> String.replace(~r/[\{\}]/, "")
    |> String.replace(~r/,.+/, "")
  end

  defp alias_with_as?(%{as: as, module: module}) do
    module |> Module.split() |> List.last() != as |> Module.split() |> List.last()
  end

  defp replace_aliases(reorganized_aliases, source_code_lines) do
    source_code_map =
      source_code_lines
      |> Enum.with_index(1)
      |> Enum.into(%{}, &{elem(&1, 1), elem(&1, 0)})

    Enum.reduce(reorganized_aliases, source_code_map, fn reorganized_alias, new_source_code_map ->
      indentation =
        source_code_map
        |> Map.get(reorganized_alias.line)
        |> String.split(~r/\S/)
        |> List.first()

      %{
        new_source_code_map
        | reorganized_alias.line => render_alias(reorganized_alias, indentation)
      }
    end)
    |> Enum.into([], &elem(&1, 1))
  end

  defp render_alias(%{module: module, as: as}, indentation) do
    if alias_with_as?(%{as: as, module: module}) do
      "#{indentation}alias #{Macro.to_string(module)}, as: #{Macro.to_string(as)}"
    else
      "#{indentation}alias #{Macro.to_string(module)}"
    end
  end
end

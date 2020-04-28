defmodule AliasFormatterTest do
  @moduledoc false

  use ExUnit.Case

  describe "format_code/1" do
    test "sort aliases alphabetically in a module" do
      input = """
      defmodule Foo do
        alias Foo.ModuleA
        alias Foo.ModuleC
        alias Foo.ModuleB
      end
      """

      expected_output = """
      defmodule Foo do
        alias Foo.ModuleA
        alias Foo.ModuleB
        alias Foo.ModuleC
      end
      """

      assert AliasFormatter.format_code(input) == expected_output
    end

    test "it keeps the file structure" do
      input = """
      defmodule Foo do
        # comment 1

        alias Foo.ModuleA
        alias Foo.ModuleC
        alias Foo.ModuleB

        # comment 2

        def fun do
          "test"
        end
      end
      """

      expected_output = """
      defmodule Foo do
        # comment 1

        alias Foo.ModuleA
        alias Foo.ModuleB
        alias Foo.ModuleC

        # comment 2

        def fun do
          "test"
        end
      end
      """

      assert AliasFormatter.format_code(input) == expected_output
    end

    test "puts aliases with defined 'as' to the end" do
      input = """
      defmodule Foo do
        alias Foo.ModuleA, as: Bar
        alias Foo.ModuleC
        alias Foo.ModuleB
      end
      """

      expected_output = """
      defmodule Foo do
        alias Foo.ModuleB
        alias Foo.ModuleC
        alias Foo.ModuleA, as: Bar
      end
      """

      assert AliasFormatter.format_code(input) == expected_output
    end

    test "deals with nested modules" do
      input = """
      defmodule Foo do
        alias Foo.ModuleA
        alias Foo.ModuleC
        alias Foo.ModuleB

        defmodule Bar do
          alias Foo.Bar.ModuleA
          alias Foo.Bar.ModuleC
          alias Foo.Bar.ModuleB
        end
      end
      """

      expected_output = """
      defmodule Foo do
        alias Foo.ModuleA
        alias Foo.ModuleB
        alias Foo.ModuleC

        defmodule Bar do
          alias Foo.Bar.ModuleA
          alias Foo.Bar.ModuleB
          alias Foo.Bar.ModuleC
        end
      end
      """

      assert AliasFormatter.format_code(input) == expected_output
    end
  end
end

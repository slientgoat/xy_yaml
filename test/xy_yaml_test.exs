defmodule XyYamlTest do
  use ExUnit.Case
  doctest XyYaml

  test "use origin when changes == nil or changes == origin" do
    changes = nil
    origin = %{k1: %{k2: %{k3: %{k4: :v4}}}}
    assert XyYaml.merge(changes, origin) == %{k1: %{k2: %{k3: %{k4: :v4}}}}
    assert XyYaml.merge(changes, %{}) == %{}
    assert XyYaml.merge(origin, origin) == %{k1: %{k2: %{k3: %{k4: :v4}}}}
  end

  test "use changes when changes key-value diffrent with origin" do
    changes = %{k1: %{k2: %{k3: %{k4: :different}}}}
    origin = %{k1: %{k2: %{k3: %{k4: :v4}}}}
    assert XyYaml.merge(changes, origin) == %{k1: %{k2: %{k3: %{k4: :different}}}}

    changes = %{k1: %{k2: %{k3: %{k4: nil}}}}
    assert XyYaml.merge(changes, origin) == %{k1: %{k2: %{k3: %{k4: nil}}}}
  end

  test "use origin and keep the exisited key-value of changes when origin more keys than changes" do
    changes = %{k1: %{k2: %{k3: %{k4: :different}}}}
    origin = %{k1: %{k2: %{k3: %{k4: :v4, more_k5: nil}}}, more_k1: :more_v1}

    assert XyYaml.merge(changes, origin) == %{
             k1: %{k2: %{k3: %{k4: :different, more_k5: nil}}},
             more_k1: :more_v1
           }
  end

  test "use origin when the origin key-type diffrent with changes" do
    changes = %{k1: %{k2: %{k3: %{k4: :different}}}}
    origin = %{k1: %{k2: :v2}}
    assert XyYaml.merge(changes, origin) == %{k1: %{k2: :v2}}
  end

  test "use origin when the origin key had been removed" do
    changes = %{k1: %{k2: %{k3: %{k4: :v4, more_k5: nil}}}, more_k1: :more_v1}
    origin = %{k1: %{k2: %{k3: %{k4: :v4}}}, more_k1: :more_v1}
    assert XyYaml.merge(changes, origin) == %{k1: %{k2: %{k3: %{k4: :v4}}}, more_k1: :more_v1}
  end

  test "use origin when theirs value's format not match" do
    changes = %{
      k1: %{k2: %{k3: %{k4: :still_as_atom}}},
      more_k1: "will_be_number1",
      more_k2: "never_change"
    }

    origin = %{k1: %{k2: %{k3: %{k4: :v4}}}, more_k1: 1, more_k2: ""}

    assert XyYaml.merge(changes, origin) == %{
             k1: %{k2: %{k3: %{k4: :still_as_atom}}},
             more_k1: 1,
             more_k2: "never_change"
           }
  end
end

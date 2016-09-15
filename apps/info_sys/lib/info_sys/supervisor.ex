defmodule InfoSys.Supervisor do
  @moduledoc """
  Supervisor that starts processes that
  query third party APIs. The processes
  are started dynamically as needed, therefore
  using strategy :simple_one_for_one. If a
  particular process dies, it stays dead, 
  therefore using restart strategy :temporary.
  """

  use Supervisor

  @doc """
  Start the supervisor process.
  """
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  In this init function, the children (even though
  defined), are not started yet. The code inside
  the init function is just a template for a
  children to be created dynamically when
  the supervisor wants to.
  """
  def init(_opts) do
    # This is a template for children process
    # Children will stay die when they die
    children = [
      worker(InfoSys, [], restart: :temporary)
    ]

    # Children will be started dynamically
    supervise(children, strategy: :simple_one_for_one)
  end
end

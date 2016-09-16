defmodule InfoSys do
  @moduledoc """
  Main module of this InfoSys program.
  This module serves as the proxy for the 
  actual backend engine. This means, 
  it will generically become the worker
  to query any kind of backends without 
  actually having specific implementation
  about the backend.
  """

  use Application

  @doc """
  This is where this whole application starts.
  This application starts by starting its supervisor.
  """
  def start(_type, _args) do
    InfoSys.Supervisor.start_link()
  end

  @backends [Rumbl.InfoSys.Wolfram]

  defmodule Result do
    @shortdoc """
    Struct to store the result of  a backend.
    """

    defstruct score: 0, 
      text: nil, 
      url: nil,
      backend: nil
  end

  @doc """
  This is the main function of this module.
  This will be used by outside function and
  this will spawn a process for each specific
  available backend, it will wait for each 
  completion of query and return all the result.
  """
  def compute(query, opts \\ []) do
    limit = opts[:limit] || 10
    backends = opts[:backends] || @backends

    backends
    |> Enum.map(&spawn_query(&1, query, limit))
    |> await_results(opts)
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(limit)
  end

  @doc """
  Spawn a backend process as a child
  under the supervision of InfoSys.Supervisor.

  """
  def spawn_query(backend, query, limit) do
    query_ref = make_ref()

    # This will be passed to start_link/5 below function
    opts = [backend, query, query_ref, self(), limit]

    {:ok, pid} = Supervisor.start_child(InfoSys.Supervisor, opts)
    
    # Monitor the process.
    # Also sends the monitor pid so we can
    # tell the monitor to ignore a child later.
    monitor_ref = Process.monitor(pid)

    {pid, monitor_ref, query_ref}
  end

  @doc """
  Wait computation results by recursively
  waiting for each children. We wait 5 seconds
  for all children to complete their task.
  """
  def await_results(children, opts) do
    timeout = opts[:timeout] || 5000
    timer = Process.send_after(self(), :timedout, timeout)
    results = await_result(children, [], :infinity)

    cleanup(timer)

    results
  end

  @doc """
  Recursively waiting for each children. It 
  doesn't care whether a children has failed
  its computation or not.
  """
  def await_result([], acc, _), do: acc
  def await_result([head | tail], acc, timeout) do
    {pid, monitor_ref, query_ref} = head
    receive do
      {:results, ^query_ref, results} ->
        # Demonitor the child process that
        # completed their task, :flush option is
        # so that :DOWN message is removed from
        # the inbox in case it's delivered before
        # dropping the monitor.
        Process.demonitor(monitor_ref, [:flush])
        await_result(tail, results ++ acc, timeout)

      {:DOWN, ^monitor_ref, :process, ^pid, _reason} ->
        # Match the monitored child process in case
        # there is a :DOWN message
        await_result(tail, acc, timeout)

      :timedout ->
        kill(pid, monitor_ref)
        await_result(tail, acc, 0)
    after timeout ->
      kill(pid, monitor_ref)
      await_result(tail, acc, 0)
    end
  end

  @doc """
  Since this is a generic proxy module,
  what it actually does is start a specific backend process
  that does the actual work of querying with its specific
  implementation.
  """
  def start_link(backend, query, query_ref, owner, limit) do
    backend.start_link(query, query_ref, owner, limit)
  end

  defp kill(pid, ref) do
    Process.demonitor(ref, [:flush])
    Process.exit(pid, :kill)
  end

  defp cleanup(timer) do
    :erlang.cancel_timer(timer)
    receive do
      :timedout -> :ok
    after
      0 -> :ok
    end
  end
end

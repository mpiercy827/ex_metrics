defmodule ExMetricsTest do
  use ExUnit.Case
  import Mimic

  setup :set_mimic_global

  setup _context do
    MetricsAgent.start_link()

    stub(ExMetrics, :timing, fn name, value, options ->
      MetricsAgent.set({name, value, :timing, options})
    end)

    stub(ExMetrics, :histogram, fn name, value, options ->
      MetricsAgent.set({name, value, :histogram, options})
    end)

    :ok
  end

  describe "start/0" do
    test "starts ExMetrics by opening a UDP socket" do
      assert ExMetrics.start() == :ok
    end

    test "sets statix config using ex_metrics config" do
      Application.put_env(:ex_metrics, :host, "localhost")
      Application.put_env(:ex_metrics, :port, 8125)

      assert ExMetrics.start() == :ok
      assert Application.get_env(:statix, :host) == "localhost"
      assert Application.get_env(:statix, :port) == 8125
    end
  end

  describe "time/3" do
    test "records the time taken to execute a function as a timing metric" do
      value = ExMetrics.time(fn -> 1 + 2 end, "ex_metrics.add", [])
      {metric_name, time, :timing, []} = MetricsAgent.get()

      assert value == 3
      assert metric_name == "ex_metrics.add"
      assert is_float(time)
    end
  end

  describe "histogram_time/3" do
    test "records the time taken to execute a function as a histogram metric" do
      value = ExMetrics.histogram_time(fn -> 1 + 2 end, "ex_metrics.add", [])
      {metric_name, time, :histogram, []} = MetricsAgent.get()

      assert value == 3
      assert metric_name == "ex_metrics.add"
      assert is_float(time)
    end
  end
end

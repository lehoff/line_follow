defmodule LineFollow do

  def start do
      {:ok, color_sensor} = EV3.ColorSensor.start_link(0, :in3)
      {:ok, left_motor} = EV3.Motor.start_link(0, :outB, :tacho)
      {:ok, right_motor} = EV3.Motor.start_link(1, :outC, :tacho)
      Process.register(color_sensor, :color_sensor)
      Process.register(left_motor, :left_motor)
      Process.register(right_motor, :right_motor)
      EV3.ColorSensor.set_mode(:color_sensor, :col_color)
      cpid = spawn(fn() -> controller end)
      spawn(fn() -> color_reader(cpid) end)
  end

  def forward do
    EV3.Motor.set_duty_cycle_sp(:left_motor, 50)
    EV3.Motor.set_duty_cycle_sp(:right_motor, 50)
    EV3.Motor.run(:left_motor)
    EV3.Motor.run(:right_motor)
  end

  def stop do
    EV3.Motor.stop(:left_motor)
    EV3.Motor.stop(:right_motor)
  end

  def turn_left do
    EV3.Motor.set_duty_cycle_sp(:right_motor, 25)
    EV3.Motor.set_duty_cycle_sp(:left_motor,0)
    EV3.Motor.run(:left_motor)
    EV3.Motor.run(:right_motor)
  end

  def turn_right do
    EV3.Motor.set_duty_cycle_sp(:right_motor, 0)
    EV3.Motor.set_duty_cycle_sp(:left_motor,25)
    EV3.Motor.run(:left_motor)
    EV3.Motor.run(:right_motor)
  end

  def color_reader(cpid) do
    :timer.sleep 10
    value = EV3.ColorSensor.value :color_sensor
    send(cpid, {:color, value})
    color_reader(cpid)
  end

  def controller do
    receive do
      {:color, :black} ->
        forward
        controller
      {:color, _c } ->
        stop
    end
  end


end

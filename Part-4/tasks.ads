with System;
with Ada.Real_Time; use Ada.Real_Time;
with NXT; use NXT;
-- Display --
with NXT.AVR; use NXT.AVR;
with NXT.Display; use NXT.Display;
-- Light sensor --
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
-- Ultrasonic sensor --
with NXT.Ultrasonic_Sensors; use NXT.Ultrasonic_Sensors;
with NXT.Ultrasonic_Sensors.Ctors; use NXT.Ultrasonic_Sensors.Ctors;
with Interfaces; use Interfaces;
-- For Motors --
with NXT.Motors.Simple; use NXT.Motors.Simple;
with NXT.Motors.Simple.Ctors; use NXT.Motors.Simple.Ctors;
with NXT.Motor_Encoders; use NXT.Motor_Encoders;
-- For Touch Sensor --
with NXT.Touch_Sensors; use NXT.Touch_Sensors;
-- For Light Sensor --
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;

package Tasks is
  procedure Background;

private
  -- Define periods and times --
  Time_Zero_Motor : Time := Clock;
  Period_Motor : Time_Span := Milliseconds(30);
  Next_Time_Motor : Time;

  -- ButtonPressTask periods and times --
  Time_Zero_Button : Time := Clock;
  Period_Button : Time_Span := Milliseconds(100);
  Next_Time_Button : Time;
  Time_Button_Pressed : Time_Span := Milliseconds(500);

  -- DisplayTask periods and times --
  Time_Zero_Display : Time := Clock;
  Period_Display : Time_Span := Milliseconds(100);
  Next_Time_Display : Time;

  -- DistanceTask periods and times --
  Time_Zero_Distance : Time := Clock;
  -- The DistanceTask's period needs to be less than the motor! --
  Period_Distance : Time_Span := Milliseconds(20);
  Next_Time_Distance: Time;

  -- Touch Sensor --
  Bumper : Touch_Sensor (Sensor_4);

  -- Ultrasonic Sensor --
  Sonar : Ultrasonic_Sensor := Make (Sensor_1);

  -- Motor Sensors --
  Wheel_B : Simple_Motor := Make(Motor_B);
  Wheel_C : Simple_Motor := Make(Motor_C);

  -- Light Sensor --
  Light_Sensor3 : Light_Sensor := Make(Sensor_3, Floodlight_On => True);

  -- PRIO VARIABLES --
  PRIO_GET : Integer := 0;
  PRIO_IDLE : Integer := 1;
  PRIO_DIST : Integer := 2;
  PRIO_STOP : Integer := 3;
  PRIO_INIT : Integer := 4;
  PRIO_SET_IDLE : Integer := 5;
  PRIO_SET_DIST : Integer := 6;
  PRIO_SET_STOP : Integer := 7;

  -- PID Controller variables --
  -- Car Speed Default --
  Speed : PWM_Value := 30;
  -- WHITE --
  WHITE: Integer;
  -- GREY --
  GREY : Integer;
  -- BLACK --
  BLACK : Integer;
  -- AVG --
  AVG : Integer;
  -- Offset --
  OFFSET : Integer;

  -- Driving_Command Record --
  type Drive_Command is Record
    Update_Priority : Integer;
  end record;


end Tasks;

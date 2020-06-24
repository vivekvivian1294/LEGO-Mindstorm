with Ada.Real_Time; use Ada.Real_Time;
with NXT; use NXT;
--with NXT.AVR; use NXT.AVR;
-- For Light Sensor --
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
-- For touch Sensor --
with NXT.Touch_Sensors; use NXT.Touch_Sensors;
-- For Motors --
with NXT.Motors.Simple; use NXT.Motors.Simple;
with NXT.Motors.Simple.Ctors; use NXT.Motors.Simple.Ctors;
with NXT.Motor_Encoders; use NXT.Motor_Encoders;


-- Add required sensor and actuator package

package Tasks is
   procedure Background;


private
   -- Define periods and times --
   Time_Zero : Time := Clock;
   Period_Display : Ada.Real_Time.Time_Span := Milliseconds(100);
   Delay_Display : Ada.Real_Time.Time_Span := Milliseconds(1000);
   -- Define used sensor ports --
   -- Light Sensor --
   Light_Sensor3 : Light_Sensor := Make(Sensor_3, Floodlight_On => True);
   -- Touch Sensors --
  -- Active_Button : Button_Id;
   Bumper : Touch_Sensor (Sensor_1);
   -- Motor Sensors --
   Wheel_B : Simple_Motor := Make(Motor_B);
   Wheel_C : Simple_Motor := Make(Motor_C);
   -- Init sensors --
   -- Flags --
   Touch_Sensor_Button: Boolean:=false;

   --Event_id
   Event_Id: Integer := 0;
   -- for looping
   I : Integer := 0;
end Tasks;

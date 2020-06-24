with Ada.Real_Time; use Ada.Real_Time;
with NXT; use NXT;
--with NXT.AVR; use NXT.AVR;
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
  
-- Add required sensor and actuator package

package Tasks is
   procedure Background;
   
   
private
   -- Define periods and times --
   Time_Zero : Time := Clock;
   Period_Display : Ada.Real_Time.Time_Span := Milliseconds(100);
   -- Define used sensor ports --
   Light_Sensor3 : Light_Sensor := Make(Sensor_3, Floodlight_On => True);
   -- Init sensors --
   
end Tasks;


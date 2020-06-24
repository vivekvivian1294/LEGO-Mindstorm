with NXT.AVR; use NXT.AVR;
with NXT.Display; use NXT.Display;
--with NXT.Display.Concurrent; use NXT.Display.Concurrent;
with Ada.Real_Time; use Ada.Real_Time;
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;

package body Tasks is

   --------------------------
   -- Background procedure --
   --------------------------

   procedure Background is
   begin
      loop
	 null;
      end loop;
   end Background;

   -----------
   -- Tasks --
   -----------

   task HelloworldTask is
      -- define its priority higher than the main procedure --
      pragma Storage_Size (4096); -- task memory allocation --
   end HelloworldTask;

   task body HelloworldTask is
      Next_Time : Time := Time_Zero;

   begin
      -- task body starts here ---

      loop
	 -- Read light sensors and print ----
	 Clear_Screen_Noupdate;
	 Put_Line("Hello World");
	 Put("Light Sensor: ");
	 Put_Noupdate (Light_Sensor3.Light_Value);
	 New_Line;
	 if NXT.AVR.Button = Power_Button then
	    Power_Down;
	 end if;
	 Next_Time := Next_Time + Period_Display;
	 delay until Next_Time;
      end loop;
   end HelloworldTask;

end Tasks;

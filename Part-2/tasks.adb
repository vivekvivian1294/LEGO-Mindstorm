with NXT.AVR; use NXT.AVR;
with NXT.Display; use NXT.Display;
--with NXT.Display.Concurrent; use NXT.Display.Concurrent;
with Ada.Real_Time; use Ada.Real_Time;
-- Light sensors
with NXT.Light_Sensors; use NXT.Light_Sensors;
with NXT.Light_Sensors.Ctors; use NXT.Light_Sensors.Ctors;
--Touch sensor
with NXT.Touch_Sensors; use NXT.Touch_Sensors;
--with NXT.Buttons; use NXT.Buttons;

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

   ---------------
   -- Protected --
   ---------------

   protected Event is
      entry Wait(Event_Id : out Integer);
      procedure Signal(Event_Id : in Integer);
   private
      -- assign priority that is ceiling of the user tasks priority --
      Current_Event_Id : Integer; --Event data declaration
      Signalled: Boolean := False; -- This is flag for event signal
   end Event;

   protected body Event is
      entry Wait(Event_Id : out Integer) when Signalled is
      begin
	 Event_Id := Current_Event_Id;
	 Signalled := False;
	 end Wait;

	 procedure Signal (Event_Id : in Integer) is
	 begin
	    Current_Event_Id := Event_Id;
	    Signalled := True;
	 end Signal;
   end Event;


   -----------
   -- Tasks --
   -----------

   task Eventdispatcher is
       pragma Storage_Size (4096);
   end Eventdispatcher;

   task body Eventdispatcher is
      Next_Time : Time := Time_Zero;
   begin
      loop
  -- If Light_Sensor is less than 35
  if Light_Sensor3.Light_Value < 35 then
    --Send signal 0 (Stop the car)
	   Event.Signal(0);
	end if;
  -- The I is used because initially the bumper button is pressed
	if Pressed(Bumper) and I /= 0 then
  -- The delay is used here to get only one input of the pressed bumper
	   Next_Time := Next_Time + Delay_Display;
	   delay until Next_Time;
     -- Send signal 1 --
	   Event.Signal(1);
     --If the Event_Id is 0 (The motor is not running)
	    if(Event_Id = 0) then
    -- Run the motor --
	      Event.Signal(1);
	    elsif Event_Id = 1 then
      -- else if the Event_Id is 1 (the motor is running) --
      -- Stop the motor
	       Event.Signal(0);
	    end if;
	end if;
	if NXT.AVR.Button = Power_Button then
	   Event.Signal(2);
	end if;
	    I :=  1;
      Next_Time := Next_Time + Period_Display;
	 delay until Next_Time;
      end loop;
   end Eventdispatcher;


   task HelloworldTask is
      -- define its priority higher than the main procedure --
      pragma Storage_Size (4096); -- task memory allocation --
   end HelloworldTask;

   task body HelloworldTask is
      Next_Time : Time := Time_Zero;

   begin
      -- task body starts here ---
      --NXT.AVR.Await_Data_Available;
      loop

	 -- read light sensors and print --

	 Event.Wait(Event_Id);
   -- If Id 0 then stop the motor --
	 if Event_Id = 0 then
	    Wheel_B.Stop;
	    Wheel_C.Stop;
	    Wheel_B.Set_Power(0);
	    Wheel_C.Set_Power(0);
  -- if Id 1 then go forward
	 elsif Event_Id = 1 then
	    Wheel_B.Set_Power (30);
	    Wheel_C.Set_Power (30);
	    Wheel_B.Forward;
	    Wheel_C.Forward;
	 end if;
   -- if Id 2 then stop motor and power down (motors needs to be stopped, if they are not stopped they should be spinning during the power down function)
	 if Event_Id = 2 then
	    Wheel_B.Stop;
	    Wheel_C.Stop;
	    Wheel_B.Set_Power(0);
	    Wheel_C.Set_Power(0);
	    Power_Down;
	 end if;
	 Next_Time := Next_Time + Period_Display;
	 delay until Next_Time;
      end loop;
   end HelloworldTask;
end Tasks;

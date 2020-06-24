package body Tasks is

  -- Background procedure --
  procedure Background is
  begin
    loop
      null;
    end loop;
  end Background;

 -- Driving command --
 protected Driving_Command is
 -- Procedure / Function --
   procedure Change_Driving_Command (In_Driving_Record : In Drive_Command; Out_Driving_Record : Out Drive_Command);
-- Private Variables  Store variable--
   private
    Obj_Driving_Record : Drive_Command;
  end Driving_Command;
  --  Procedure / Function Change_Driving_Command code --
  protected body Driving_Command is
    procedure Change_Driving_Command(In_Driving_Record : In Drive_Command; Out_Driving_Record : Out Drive_Command) is
  -- Variable that returns --
      Temp_Driving_Record : Drive_Command;
    begin
  -- If PRIO_GET, get the the private variable.
      if In_Driving_Record.Update_Priority = PRIO_GET then
  -- Update the private variable. --
        Temp_Driving_Record := Obj_Driving_Record;
  -- Get the private variable. --
        Out_Driving_Record := Temp_Driving_Record;


  -- if PRIO_BUTTON, get the Input, assign it to private variable --
        elsif In_Driving_Record.Update_Priority = PRIO_BUTTON then
  -- Set the temporary variable --
          Temp_Driving_Record.Update_Priority := In_Driving_Record.Update_Priority;
          Temp_Driving_Record.Car_Speed := In_Driving_Record.Car_Speed;
          Temp_Driving_Record.Driving_Duration := In_Driving_Record.Driving_Duration;
  -- Update the private variable --
          Obj_Driving_Record := Temp_Driving_Record;


  -- if PRIO_DIST, get the Input, assign it to private variable --
        elsif In_Driving_Record.Update_Priority = PRIO_DIST then
  -- if Priority is not PRIO_BUTTON --
          if Obj_Driving_Record.Update_Priority /= PRIO_BUTTON then
  -- Set the temporary variable --
            Temp_Driving_Record.Update_Priority := In_Driving_Record.Update_Priority;
            Temp_Driving_Record.Car_Speed := In_Driving_Record.Car_Speed;
            Temp_Driving_Record.Driving_Duration := In_Driving_Record.Driving_Duration;
  -- Update the private variable --
            Obj_Driving_Record := Temp_Driving_Record;
          end if;


  -- if PRIO_IDLE, assign it to private variable --
          elsif In_Driving_Record.Update_Priority = PRIO_IDLE then
  -- Set the temporary variable --
            if Obj_Driving_Record.Update_Priority < PRIO_DIST  then
            Temp_Driving_Record.Update_Priority := In_Driving_Record.Update_Priority;
            Temp_Driving_Record.Car_Speed := In_Driving_Record.Car_Speed;
            Temp_Driving_Record.Driving_Duration := In_Driving_Record.Driving_Duration;
  -- Update the private variable --
            Obj_Driving_Record := Temp_Driving_Record;
          end if;
  -- if PRIO_SET_IDLE, set the Update_Priority value to PRIO_IDLE --
          elsif In_Driving_Record.Update_Priority = PRIO_SET_IDLE then
  -- Set the temporary variable --
            Temp_Driving_Record.Update_Priority := PRIO_IDLE;
            Temp_Driving_Record.Car_Speed := In_Driving_Record.Car_Speed;
            Temp_Driving_Record.Driving_Duration := In_Driving_Record.Driving_Duration;
  -- Update the private variable --
            Obj_Driving_Record := Temp_Driving_Record;
  -- if PRIO_SET_IDLE, set the Update_Priority value to PRIO_IDLE --
          elsif In_Driving_Record.Update_Priority = PRIO_SET_DIST then
  -- Set the temporary variable --
            Temp_Driving_Record.Update_Priority := PRIO_DIST;
            Temp_Driving_Record.Car_Speed := In_Driving_Record.Car_Speed;
            Temp_Driving_Record.Driving_Duration := In_Driving_Record.Driving_Duration;
  -- Update the private variable --
            Obj_Driving_Record := Temp_Driving_Record;
      end if;
    end Change_Driving_Command;
  end Driving_Command;



  -- MotorControlTask controls the motors by looking the PRIO values --
  task MotorControl is
    pragma Storage_Size (2048);
  end MotorControl;
  -- MotorControlTask body / code --
    task body MotorControl is
  -- Private Change_Driving_Command variable --
      Driving_Record : Drive_Command;
  -- Time_Start variable to use it for counting the duration --
      Time_Start : Time := Clock;
  -- Flag variables for updating Time_Start --
      Flag_PRIO_BUTTON : Boolean := True;
      Flag_PRIO_IDLE : Boolean := True;
      Flag_PRIO_DIST : Boolean := True;

    begin
  -- Initialize Driving_Record to PRIO_IDLE --
      Driving_Record.Update_Priority := PRIO_IDLE;
      Driving_Record.Car_Speed := 30;
      Driving_Record.Driving_Duration := ONE;
      Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
      loop
  -- Set Update_Priority to PRIO_GET and get the current priority --
        Driving_Record.Update_Priority := PRIO_GET;
        Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
  -- FOR DEBUGGING PURPOSES --
  --      if Driving_Record.Update_Priority = PRIO_BUTTON then
  --        Put_Line("BUTTON");
  --      elsif Driving_Record.Update_Priority = PRIO_DIST then
  --        Put_Line("DISTANCE");
  --      elsif Driving_Record.Update_Priority = PRIO_IDLE then
  --        Put_Line("IDLE");
  --      else
  --        Put_Line("PRIO NOT FOUND!");
  --      end if;
  -- If PRIO_BUTTON, go backwards for duration --
        if Driving_Record.Update_Priority = PRIO_BUTTON then
  --Set Time_Start and change flags values --
            if Flag_PRIO_BUTTON = True then
              Time_Start := Clock;
              Flag_PRIO_BUTTON := False;
              Flag_PRIO_DIST := True;
              Flag_PRIO_IDLE := True;
            end if;
  -- If Duration greater than 0, go backwards --
        if Driving_Record.Driving_Duration - (Clock - Time_Start) > ZERO then
  -- Set Power of motors --
          Wheel_B.Set_Power (Driving_Record.Car_Speed);
          Wheel_C.Set_Power (Driving_Record.Car_Speed);
  -- Run backwards (Wheel A is on the opposite side) --
          Wheel_B.Backward;
          Wheel_C.Backward;

  -- If Duration  equal to or less than 0, stop the car --
        elsif Driving_Record.Driving_Duration - (Clock - Time_Start) <= ZERO then
  -- Stop all wheels and define Speed to 0 --
          Driving_Record.Car_Speed := 0;
    	    Wheel_B.Set_Power (Driving_Record.Car_Speed);
    	    Wheel_C.Set_Power (Driving_Record.Car_Speed);
          Wheel_B.Stop;
          Wheel_C.Stop;
  -- Set the priority to PRIO_IDLE --
          Driving_Record.Update_Priority := PRIO_SET_IDLE;
  -- Set all flags true --
     	    Flag_PRIO_BUTTON := True;
     	    Flag_PRIO_IDLE := True;
     	    Flag_PRIO_DIST := True;
  -- Update Driving Command with PRIO_IDLE and duration 1 second --
     	    Driving_Record.Car_Speed := 30;
     	    Driving_Record.Driving_Duration := ONE;
     	    Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
        end if;
  -- if PRIO_DIST, run forwards / backwards for duration
      elsif Driving_Record.Update_Priority = PRIO_DIST then
  --Set Time_Start and change flags values --
        if Flag_PRIO_DIST = True then
          Time_Start := Clock;
          Flag_PRIO_BUTTON := True;
          Flag_PRIO_DIST := False;
          Flag_PRIO_IDLE := True;
        end if;
  -- If Duration greater than 0, go backwards/forward, speed decides --
        if Driving_Record.Driving_Duration - (Clock - Time_Start) > ZERO then
  -- if Car_Speed positive, move forward
          if Driving_Record.Car_Speed > 0 then
  -- Set Power of motors --
          Wheel_B.Set_Power (Driving_Record.Car_Speed);
          Wheel_C.Set_Power (Driving_Record.Car_Speed);
  -- Run forward --
          Wheel_B.Forward;
          Wheel_C.Forward;
   -- else Car_Speed negative, move backwards --
        else
  -- Assign the speed to positive value --
          Driving_Record.Car_Speed := 30;
  -- Set Power of motors --
          Wheel_B.Set_Power (Driving_Record.Car_Speed);
          Wheel_C.Set_Power (Driving_Record.Car_Speed);
  -- Run backward (Wheel A is on the opposite side) --
          Wheel_B.Backward;
          Wheel_C.Backward;
        end if;
  -- If Duration  equal to or less than 0, stop the car --
        elsif Driving_Record.Driving_Duration - (Clock - Time_Start) <= ZERO then
  -- Stop all wheels and define Speed to 0 --
          Driving_Record.Car_Speed := 0;
          Wheel_B.Set_Power (Driving_Record.Car_Speed);
          Wheel_C.Set_Power (Driving_Record.Car_Speed);
          Wheel_B.Stop;
          Wheel_C.Stop;
  -- Set the priority to PRIO_IDLE --
          Driving_Record.Update_Priority := PRIO_SET_IDLE;
  -- Set all flags true --
          Flag_PRIO_BUTTON := True;
          Flag_PRIO_IDLE := True;
          Flag_PRIO_DIST := True;
  -- Update Driving Command with PRIO_IDLE and duration 1 second --
  -- Run Change_Driving_Command first to set to PRIO_IDLE --
          Driving_Record.Car_Speed := 30;
          Driving_Record.Driving_Duration := ONE;
          Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
        end if;

  -- if PRIO_IDLE, go forwards until duration
      elsif Driving_Record.Update_Priority = PRIO_IDLE then
  --Set Time_Start and change flags values --
        if Flag_PRIO_IDLE = True then
          Time_Start := Clock;
          Flag_PRIO_BUTTON := True;
          Flag_PRIO_DIST := True;
          Flag_PRIO_IDLE := False;
        end if;
  -- If Duration greater than 0, go backwards/forward, speed decides --
        if Driving_Record.Driving_Duration - (Clock - Time_Start) > ZERO then
  -- Set Power of motors --
          Wheel_B.Set_Power (Driving_Record.Car_Speed);
          Wheel_C.Set_Power (Driving_Record.Car_Speed);
  -- Run forwards --
          Wheel_B.Forward;
          Wheel_C.Forward;
  -- If Duration  equal to or less than 0, stop the car --
        elsif Driving_Record.Driving_Duration - (Clock - Time_Start) <= ZERO then
  -- Stop all wheels and define Speed to 0 --
          Driving_Record.Car_Speed := 0;
          Wheel_B.Set_Power (Driving_Record.Car_Speed);
          Wheel_C.Set_Power (Driving_Record.Car_Speed);
          Wheel_B.Stop;
          Wheel_C.Stop;
  -- Set the priority to PRIO_IDLE --
          Driving_Record.Update_Priority := PRIO_IDLE;
  -- Set all flags true --
          Flag_PRIO_BUTTON := True;
          Flag_PRIO_IDLE := True;
          Flag_PRIO_DIST := True;
  -- Update Driving Command with PRIO_IDLE and duration 1 second --
  -- Run Change_Driving_Command first to set to PRIO_IDLE --
     	    Driving_Record.Car_Speed := 30;
          Driving_Record.Driving_Duration := ONE;
          Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
        end if;
      end if;
  -- Wait until next period --
        Next_Time_Motor := Next_Time_Motor + Period_Motor;
  	    delay until Next_Time_Motor;
      end loop;
    end MotorControl;

  -- ButtonPressTask utilizes the power_off button for turning off, and the touch sensor for going backwards the car --
  task ButtonpressTask is
    pragma Storage_Size (2048);
  end ButtonpressTask;
  -- ButtonpressTask body / code --
  task body ButtonpressTask is
  -- Private Change_Driving_Command variable --
    Driving_Record : Drive_Command;
  begin
    loop
  -- If  button pressed, set PRIO_BUTTON and Change_Driving_Command
      if Pressed (Bumper) then
        Driving_Record.Update_Priority := PRIO_BUTTON;
        Driving_Record.Driving_Duration := ONE;
        Driving_Record.Car_Speed := 30;
        Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
      end if;
  -- If Power button is pressed, power off car --
      if NXT.AVR.Button = Power_Button then
        Wheel_B.Stop;
        Wheel_C.Stop;
        Power_Down;
      end if;
  -- Wait until next period --
      Next_Time_Button := Next_Time_Button + Period_Button;
      delay until Next_Time_Button;
    end loop;
  end ButtonpressTask;

  -- DistanceTask is used for the ultrasonic sensor --
  task DistanceTask is
    pragma Storage_Size (2048);
  end DistanceTask;
  -- DistanceTask body / code --
  task body DistanceTask is
  -- Private Change_Driving_Command variable --
    Driving_Record : Drive_Command;
  -- Detected, Num_Detected and Index are for Ultrasonic_Sensor
    Detected : Distances (1 .. 8);
    Num_Detected : Natural;
    Index : Natural;
  begin
  -- The driving duration should be one --
    Driving_Record.Driving_Duration := ONE;
  -- Initialize Priority to PRIO_DIST --
    Driving_Record.Update_Priority := PRIO_DIST;
  -- Reset Sonar and set mode to ping
    Sonar.Reset;
    Sonar.Set_Mode (Ping);
    NXT.AVR.Await_Data_Available;
    loop
      Sonar.Ping;
      Sonar.Get_Distances (Detected, Num_Detected);
  -- if no signal detected, go to PRIO_IDLE i.e. go forward --
      if Num_Detected = 0 then
        Driving_Record.Update_Priority := PRIO_DIST;
        Driving_Record.Car_Speed := 30;
        Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
      else
        Index := Detected'First;
        Inner_Loop:
  -- Run through the signals --
          for K in 1 .. Num_Detected loop
  -- if Signal's value is 50 or less go back --
            --Put_Noupdate (K); Put(": "); Put_Noupdate(Integer (Detected (Index))); New_Line;
            if Detected(Index) <= 50 then
              Driving_Record.Car_Speed := -30;
              Driving_Record.Update_Priority := PRIO_DIST;
              Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
  -- Delay until next period --
              Next_Time_Distance := Next_Time_Distance + Period_Distance;
              delay until Next_Time_Distance;
              --exit Inner_Loop;
  -- else go forward --
            else
              Driving_Record.Car_Speed := 30;
              Driving_Record.Update_Priority := PRIO_DIST;
              Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
  -- Delay until next period --
              Next_Time_Distance := Next_Time_Distance + Period_Distance;
              delay until Next_Time_Distance;
              --exit Inner_Loop;
            end if;
            Index := Index + 1;
  -- Delay until next period --
            Next_Time_Distance := Next_Time_Distance + Period_Distance;
            delay until Next_Time_Distance;
          end loop Inner_Loop;
      end if;
      Next_Time_Distance := Next_Time_Distance + Period_Distance;
      delay until Next_Time_Distance;
    end loop;
  end DistanceTask;


  -- DisplayTask is used for providing some information --
        task DisplayTask is
        pragma Storage_Size (1024);
     end DisplayTask;
  task body  DisplayTask is
  begin
     NXT.AVR.Await_Data_Available;
     loop
  -- Print the Light sensor value --
        Clear_Screen_Noupdate;
        Put_Noupdate("Light Sensor: ");
        Put_Noupdate (Light_Sensor3.Light_Value);
        New_Line;
        Next_Time_Display := Next_Time_Display + Period_Display;
        delay until Next_Time_Display;
     end loop;
  end DisplayTask;

end Tasks;

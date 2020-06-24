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
      --Temp_Driving_Record : Drive_Command;
    begin
      -- IF PRIO_GET, get the protected object Obj_Driving_Record
        if In_Driving_Record.Update_Priority = PRIO_GET then
          Out_Driving_Record := Obj_Driving_Record;
      -- If PRIO_SET_DIST, set the update priority of the protected object to PRIO_DIST
        elsif In_Driving_Record.Update_Priority = PRIO_SET_DIST then
          Obj_Driving_Record := In_Driving_Record;
          Obj_Driving_Record.Update_Priority := PRIO_DIST;
      -- IF PRIO_SET_STOP, set the update priority of the protected object to PRIO_BUTTON
        elsif In_Driving_Record.Update_Priority = PRIO_SET_STOP then
          Obj_Driving_Record := In_Driving_Record;
          Obj_Driving_Record.Update_Priority := PRIO_STOP;
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
  -- Declare Error value
      Error : Integer;
      Turn : PWM_Value;
  -- Flag for the negative Errors --
      Flag_Pos_Error : Boolean;
    begin
  -- Initialize Driving_Record to PRIO_IDLE --

      loop
  -- Set Update_Priority to PRIO_GET and get the current priority --
        Driving_Record.Update_Priority := PRIO_GET;
        Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
        if(Driving_Record.Update_Priority = PRIO_DIST) then
  -- Get the error --
          Error := Light_Sensor3.Light_Value - OFFSET;
  -- Define the Turn values from the error values --
          if(Error = 0) then
            Turn := 0;
            Flag_Pos_Error := True;
          elsif (Error < 0 AND Error > - 5) then
            Turn := 4;
            Flag_Pos_Error := False;
          elsif (Error < -5 AND Error > - 10) then
            Turn := 8;
            Flag_Pos_Error := False;
          elsif (Error < -10 AND Error > - 15) then
            Turn := 12;
            Flag_Pos_Error := False;
          elsif (Error < -15 ) then
            Turn := 16;
            FLag_Pos_Error := False;
          elsif (Error < 0 AND Error > 5) then
            Turn := 4;
            Flag_Pos_Error := True;
          elsif (Error > 5 AND Error < 10) then
            Turn := 8;
            Flag_Pos_Error := True;
          elsif (Error > 10 AND Error < 15) then
            Turn := 12;
            Flag_Pos_Error := True;
          elsif (Error > 15) then
            Turn := 16;
            Flag_Pos_Error := True;
          end if;
          -- If Flag_Pos_Error is true turn right --
          if FLag_Pos_Error = True then
            Wheel_B.Set_Power(Speed + Turn);
            Wheel_C.Set_Power(Speed - Turn);
          -- If Flag_Pos_Error is true turn left --
          elsif Flag_Pos_Error = False then
            Wheel_B.Set_Power(Speed - Turn);
            Wheel_C.Set_Power(Speed + Turn);
          end if;
          Wheel_B.Forward;
          Wheel_C.Forward;
        elsif Driving_Record.Update_Priority = PRIO_STOP then
  -- Stop the car --
          Wheel_B.Set_Power(0);
          Wheel_C.Set_Power(0);
          Wheel_B.Stop;
          Wheel_C.Stop;
        end if;
  -- Delay until next period --
        Next_Time_Motor := Next_Time_Motor + Period_Motor;
  	    delay until Next_Time_Motor;
      end loop;
    end MotorControl;

  -- ButtonPressTask utilizes the power_off button for turning off, and the touch sensor initializing the WHITE, BLACK and OFFSET variables --
  task ButtonpressTask is
    pragma Storage_Size (2048);
  end ButtonpressTask;
  -- ButtonpressTask body / code --
  task body ButtonpressTask is
  -- Private Change_Driving_Command variable --
    Driving_Record : Drive_Command;
  -- Integer I for removing the case that the button begins as pressed --
    I : Integer := 0;
  -- Flags for colour initialization --
    white_Flag : Boolean := False;
    black_Flag : Boolean := False;
    Done_Flag : Boolean := False;
  begin
    NXT.AVR.Await_Data_Available;
    loop
  -- Print Light sensor value, WHITE, BLACK and OFFSET --
      Clear_Screen_Noupdate;
      Put_Noupdate("CURRENT : ");Put_Noupdate(Light_Sensor3.Light_Value);New_Line;
      Put_Noupdate("WHITE : ");Put_Noupdate(WHITE);New_Line;
      Put_Noupdate("BLACK : ");Put_Noupdate(BLACK);New_Line;
      Put_Noupdate("OFFSET : ");Put_Noupdate(OFFSET);New_Line;
  -- If  button pressed, set White value and Change_Driving_Command
      if Pressed (Bumper) and I /= 0 and white_Flag = False and black_Flag = false then
          Next_Time_Button := Next_Time_Button + Time_Button_Pressed;
          delay until Next_Time_Button;
  -- Initialize WHITE Value --
          WHITE := Light_Sensor3.Light_Value;
          White_Flag := True;
      end if;
  -- If  button pressed, set White value
      if Pressed (Bumper) and I /= 0 and white_Flag = True and black_Flag = false then
          Next_Time_Button := Next_Time_Button + Time_Button_Pressed;
          delay until Next_Time_Button;
  -- Initialize BLACK Value --
          BLACK := Light_Sensor3.Light_Value;
          Black_Flag := True;
      end if;
  -- If  button pressed, set OFFSET value and Change_Driving_Command
      if Pressed (Bumper) and I /= 0 and white_Flag = True and black_Flag = True and Done_Flag = False then
          Next_Time_Button := Next_Time_Button + Time_Button_Pressed;
          delay until Next_Time_Button;
  -- Initialize OFFSET Value --
          OFFSET := (WHITE+BLACK)/2;
  -- Initialize and Set priority to PRIO_DIST --
          Driving_Record.Update_Priority := PRIO_SET_DIST;
          Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
          Done_Flag := True;
      end if;
  -- If Power button is pressed, power off car --
      if NXT.AVR.Button = Power_Button then
        Wheel_B.Stop;
        Wheel_C.Stop;
        Power_Down;
      end if;
  -- Wait until next period --
      I := 1;
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
  -- Reset Sonar and set mode to ping
    Sonar.Reset;
    Sonar.Set_Mode (Ping);
    NXT.AVR.Await_Data_Available;
    loop

      -- Get the priority through PRIO_GET --
      Driving_Record.Update_Priority := PRIO_GET;
      Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
        if(Driving_Record.Update_Priority = PRIO_DIST OR Driving_Record.Update_Priority = PRIO_STOP) then
              Sonar.Ping;
              Sonar.Get_Distances (Detected, Num_Detected);
  -- if no signal detected, Stop --
              if Num_Detected = 0 then
                Driving_Record.Update_Priority := PRIO_SET_DIST;
                Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
              else
                Index := Detected'First;
                Inner_Loop:
  -- Run through the signals --
                  for K in 1 .. Num_Detected loop
  -- if Signal's value is 50 or less stop the car --
                    if Detected(Index) <= 20 then
                      Driving_Record.Update_Priority := PRIO_SET_STOP;
                      Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
  -- Delay until next period --
                      Next_Time_Distance := Next_Time_Distance + Period_Distance;
                      delay until Next_Time_Distance;
  -- exit loop --
                      exit Inner_Loop;
  -- else go forward --
                    else
                      Driving_Record.Update_Priority := PRIO_SET_DIST;
                      Driving_Command.Change_Driving_Command(Driving_Record, Driving_Record);
  -- Delay until next period --
                      Next_Time_Distance := Next_Time_Distance + Period_Distance;
                      delay until Next_Time_Distance;
  -- exit loop --
                      exit Inner_Loop;
                    end if;
                    Index := Index + 1;
  -- Delay until next period --
              end loop Inner_Loop;
            end if;
        end if;

      Next_Time_Distance := Next_Time_Distance + Period_Distance;
      delay until Next_Time_Distance;
    end loop;
  end DistanceTask;
end Tasks;

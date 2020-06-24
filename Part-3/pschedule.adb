with Tasks;
with System;

procedure Pschedule is
  pragma Priority (System.Priority'First);

begin
  Tasks.Background;
end Pschedule;

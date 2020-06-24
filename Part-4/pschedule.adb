with System;
with Tasks;

procedure Pschedule is
  pragma Priority (System.Priority'First);

begin
  Tasks.Background;
end Pschedule;

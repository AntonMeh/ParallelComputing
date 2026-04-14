with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
   task type Fork is
      entry Pick_Up;
      entry Put_Down;
   end Fork;

   task body Fork is
   begin
      loop
         select
            accept Pick_Up;
            accept Put_Down;
         or
            terminate;
         end select;
      end loop;
   end Fork;

   Forks : array (0 .. 4) of Fork;

   task type Philosopher (ID : Integer);

   task body Philosopher is
      Left_Fork  : Integer := (ID + 1) mod 5;
      Right_Fork : Integer := ID;
   begin
      for I in 1 .. 10 loop
         Put_Line("Philosopher " & Integer'Image(ID) & " is thinking" & Integer'Image(I) & " times");

         if ID = 4 then
            Forks(Left_Fork).Pick_Up;
            Forks(Right_Fork).Pick_Up;
         else
            Forks(Right_Fork).Pick_Up;
            Forks(Left_Fork).Pick_Up;
         end if;

         Put_Line("Philosopher " & Integer'Image(ID) & " is eating" & Integer'Image(I) & " times");

         Forks(Left_Fork).Put_Down;
         Forks(Right_Fork).Put_Down;
      end loop;
   end Philosopher;

   P0 : Philosopher(0);
   P1 : Philosopher(1);
   P2 : Philosopher(2);
   P3 : Philosopher(3);
   P4 : Philosopher(4);
begin
   null;
end Main;

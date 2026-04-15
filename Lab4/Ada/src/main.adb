with Ada.Text_IO; use Ada.Text_IO;
with GNAT.Semaphores; use GNAT.Semaphores;

procedure Dining_Philosophers_Method1 is

   Forks : array (0 .. 4) of Counting_Semaphore(1, Default_Ceiling);

   task type Philosopher (ID : Integer);

   task body Philosopher is
      Left_Fork  : Integer := (ID + 1) mod 5;
      Right_Fork : Integer := ID;
   begin
      for I in 1 .. 10 loop
         Put_Line("Philosopher " & Integer'Image(ID) & " is thinking " & Integer'Image(I) & " times");

         if ID = 4 then
            Forks(Left_Fork).Seize;
            Forks(Right_Fork).Seize;
         else
            Forks(Right_Fork).Seize;
            Forks(Left_Fork).Seize;
         end if;

         Put_Line("Philosopher " & Integer'Image(ID) & " is eating " & Integer'Image(I) & " times");

         Forks(Left_Fork).Release;
         Forks(Right_Fork).Release;
      end loop;
   end Philosopher;

   P0 : Philosopher(0);
   P1 : Philosopher(1);
   P2 : Philosopher(2);
   P3 : Philosopher(3);
   P4 : Philosopher(4);
begin
   null;
end Dining_Philosophers_Method1;

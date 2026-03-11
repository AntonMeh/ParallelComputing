with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;

procedure Main is
   subtype Delay_Range is Integer range 1000 .. 9999;
   package Random_Delay is new Ada.Numerics.Discrete_Random(Delay_Range);
   Gen : Random_Delay.Generator;

   Quantity : Integer;

   task type Calculator (Id : Integer; Step : Integer) is
      entry Start;
      entry Stop;
   end Calculator;

   task body Calculator is
      Sum, Count : Long_Long_Integer := 0;
      Running    : Boolean := True;
   begin
      accept Start;
      while Running loop
         select 
            accept Stop do Running := False; end Stop;
         else
            Sum   := Sum + Long_Long_Integer(Step);
            Count := Count + 1;
         end select;
      end loop;
      
      Put_Line ("Thread" & Id'Image & " finished. Sum =" & Sum'Image & " Count =" & Count'Image);
   end Calculator;

   type Calc_Access is access Calculator;
begin
   Random_Delay.Reset(Gen);
   Put("Write quantity of threads: ");
   Get(Quantity);

   declare
      Delays  : array (1 .. Quantity) of Integer;
      Workers : array (1 .. Quantity) of Calc_Access;
      Order   : array (1 .. Quantity) of Integer;
      Elapsed : Integer := 0;
   begin

      for I in 1 .. Quantity loop
         Delays(I) := Random_Delay.Random(Gen);
         Order(I)  := I;
         Workers(I) := new Calculator(I, I);
         Put_Line ("Thread" & I'Image & " delay:" & Delays(I)'Image & "ms");
      end loop;

      for W of Workers loop W.Start; end loop;

      for I in 1 .. Quantity loop
         for J in 1 .. Quantity - I loop
            if Delays(Order(J)) > Delays(Order(J+1)) then
               declare T : Integer := Order(J); begin
                  Order(J) := Order(J+1); Order(J+1) := T;
               end;
            end if;
         end loop;
      end loop;

      for Id of Order loop
         declare
            Wait : Integer := Delays(Id) - Elapsed;
         begin
            delay Duration(Float(Wait) / 1000.0);
            Elapsed := Elapsed + Wait;
            Workers(Id).Stop;
            Put_Line ("[Controller] Thread" & Id'Image & " stopped at" & Elapsed'Image & "ms");
         end;
      end loop;
   end;
end Main;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Real_Time; use Ada.Real_Time;

procedure main is

   Dim : constant Integer := 1_000_000;
   Thread_Num : constant Integer := 4;

   Arr : array(1..Dim) of Integer;

   type Min_Result is record
      Val : Integer;
      Idx : Integer;
   end record;

   Start_Time, End_Time : Time;
   Elapsed : Time_Span;

   procedure Init_Arr is
      subtype Rand_Range is Integer range 100 .. 100_000;
      package Rand is new Ada.Numerics.Discrete_Random(Rand_Range);
      G : Rand.Generator;
   begin
      Rand.Reset(G);
      for I in 1..Dim loop
         Arr(I) := Rand.Random(G);
      end loop;
      Arr(99) := -172;
   end Init_Arr;

   function Part_Min(Start_Idx, End_Idx : in Integer) return Min_Result is
      Res : Min_Result := (Val => Arr(Start_Idx), Idx => Start_Idx);
   begin
      for I in Start_Idx + 1 .. End_Idx loop
         if Arr(I) < Res.Val then
            Res.Val := Arr(I);
            Res.Idx := I;
         end if;
      end loop;
      return Res;
   end Part_Min;

   protected Min_Manager is
      procedure Set_Part_Min(Res : in Min_Result);
      entry Get_Final_Min(Res : out Min_Result);
   private
      Tasks_Finished : Integer := 0;
      Global_Min : Min_Result := (Val => Integer'Last, Idx => -1);
   end Min_Manager;

   protected body Min_Manager is
      procedure Set_Part_Min(Res : in Min_Result) is
      begin
         if Res.Val < Global_Min.Val then
            Global_Min := Res;
         end if;
         Tasks_Finished := Tasks_Finished + 1;
      end Set_Part_Min;

      entry Get_Final_Min(Res : out Min_Result) when Tasks_Finished = Thread_Num is
      begin
         Res := Global_Min;
      end Get_Final_Min;
   end Min_Manager;

   task type Search_Thread is
      entry Start(Start_Idx, End_Idx : in Integer);
   end Search_Thread;

   task body Search_Thread is
      Local_Start, Local_End : Integer;
      Local_Res : Min_Result;
   begin
      accept Start(Start_Idx, End_Idx : in Integer) do
         Local_Start := Start_Idx;
         Local_End := End_Idx;
      end Start;

      Local_Res := Part_Min(Local_Start, Local_End);
      Min_Manager.Set_Part_Min(Local_Res);
   end Search_Thread;

   procedure Parallel_Min is
      Threads : array(1..Thread_Num) of Search_Thread;
      Chunk_Size : Integer := Dim / Thread_Num;
      Final_Res : Min_Result;
      S_Idx, E_Idx : Integer;
   begin
      for I in 1..Thread_Num loop
         S_Idx := (I - 1) * Chunk_Size + 1;
         E_Idx := (if I = Thread_Num then Dim else S_Idx + Chunk_Size - 1);
         Threads(I).Start(S_Idx, E_Idx);
      end loop;

      Min_Manager.Get_Final_Min(Final_Res);

      Put_Line("Min value: " & Final_Res.Val'Img);
      Put_Line("Index: " & Final_Res.Idx'Img);
   end Parallel_Min;

begin
   Put_Line("Initializing array...");
   Init_Arr;

   Put_Line("Starting parallel search with" & Thread_Num'Img & " threads...");

   Start_Time := Clock;

   Parallel_Min;

   End_Time := Clock;
   Elapsed := End_Time - Start_Time;

   Put_Line("Time: " & Duration'Image(To_Duration(Elapsed)) & " seconds");
end Main;

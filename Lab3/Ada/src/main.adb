with Ada.Text_IO; use Ada.Text_IO;
with GNAT.Semaphores; use GNAT.Semaphores;
with Ada.Containers.Indefinite_Doubly_Linked_Lists;
with Ada.Unchecked_Deallocation;

procedure Main is
   package String_Lists is new Ada.Containers.Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   Storage_Size : constant Integer := 8;
   Total_Items  : constant Integer := 10;
   Prod_Count   : constant Integer := 6;
   Cons_Count   : constant Integer := 5;

   Storage : List;

   Access_Storage : Counting_Semaphore (1, Default_Ceiling);
   Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
   Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

   task type Producer (ID : Integer; Quota : Integer);
   task type Consumer (ID : Integer; Quota : Integer);

   type Producer_Ptr is access Producer;
   type Consumer_Ptr is access Consumer;

   procedure Free_Producer is new Ada.Unchecked_Deallocation (Producer, Producer_Ptr);
   procedure Free_Consumer is new Ada.Unchecked_Deallocation (Consumer, Consumer_Ptr);

   task body Producer is
   begin
      for I in 1 .. Quota loop
         Full_Storage.Seize;
         Access_Storage.Seize;
         Storage.Append ("Item-" & ID'Img & "-" & I'Img);
         Put_Line ("Producer" & ID'Img & " added item. Total:" & Storage.Length'Img);
         Access_Storage.Release;
         Empty_Storage.Release;
         delay 0.1;
      end loop;
   end Producer;

   task body Consumer is
   begin
      for I in 1 .. Quota loop
         Empty_Storage.Seize;
         Access_Storage.Seize;
         declare
            Current_Item : String := First_Element (Storage);
         begin
            Put_Line ("Consumer" & ID'Img & " took " & Current_Item);
            Storage.Delete_First;
         end;
         Access_Storage.Release;
         Full_Storage.Release;
         delay 0.2;
      end loop;
   end Consumer;

   Producers : array (1 .. Prod_Count) of Producer_Ptr;
   Consumers : array (1 .. Cons_Count) of Consumer_Ptr;

   procedure Run_System is
      Sum_Prod, Sum_Cons : Integer := 0;
      Quota : Integer;
   begin
      Put_Line ("--- START SYSTEM ---");

      for I in 1 .. Prod_Count loop
         Quota := (if I = Prod_Count then Total_Items - Sum_Prod else Total_Items / Prod_Count);
         Sum_Prod := Sum_Prod + Quota;
         Producers (I) := new Producer (I, Quota);
      end loop;

      for I in 1 .. Cons_Count loop
         Quota := (if I = Cons_Count then Total_Items - Sum_Cons else Total_Items / Cons_Count);
         Sum_Cons := Sum_Cons + Quota;
         Consumers (I) := new Consumer (I, Quota);
      end loop;

      for I in 1 .. Prod_Count loop
         while not Producers (I)'Terminated loop
            delay 0.1;
         end loop;
         Free_Producer (Producers (I));
      end loop;

      for I in 1 .. Cons_Count loop
         while not Consumers (I)'Terminated loop
            delay 0.1;
         end loop;
         Free_Consumer (Consumers (I));
      end loop;

      Storage.Clear;
      Put_Line ("--- SYSTEM CLEANED AND STOPPED ---");
   end Run_System;

begin
   Run_System;
end Main;

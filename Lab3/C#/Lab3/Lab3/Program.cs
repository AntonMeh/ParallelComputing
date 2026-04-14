using System;
using System.Collections.Generic;
using System.Threading;

namespace Lab3
{
    internal class Program
    {
        private static int storageCapacity = 10;
        private static List<string> storage = new List<string>();

        private static Semaphore emptySlots = new Semaphore(storageCapacity, storageCapacity);
        private static Semaphore порожнійСклад = new Semaphore(0, storageCapacity);
        private static Semaphore mutex = new Semaphore(1, 1);
        static void Main(string[] args)
        {
            Console.WriteLine("Write produsers, consumers and amount of products: ");
            int[] input = Console.ReadLine().Trim().Split().Select(int.Parse).ToArray();

            int produsers = input[0];
            int consumers = input[1];
            int amount = input[2];

            Program prg  = new Program();
            prg.Start(produsers, consumers, amount);
        }
        private void Start(int prodAmount, int consAmount, int amount)
        {
            Console.WriteLine($"Start \n Needed items: {amount}");

            int[] prodQuotas = GenerateRandomQuotas(prodAmount, amount);
            for (int i = 0; i < prodAmount; i++)
            {
                int quota = prodQuotas[i];
                int id = i;
                new Thread(() => Producer(id, quota)).Start();
            }

            int[] consQuotas = GenerateRandomQuotas(consAmount, amount);
            for (int i = 0; i < consAmount; i++)
            {
                int quota = consQuotas[i];
                int id = i;
                new Thread(() => Consumer(id, quota)).Start();
            }
        }

        private int[] GenerateRandomQuotas(int count, int total)
        {
            Random rand = new Random();
            int[] quotas = new int[count];
            int currentSum = 0;

            for (int i = 0; i < count - 1; i++)
            {
                int maxPossible = total - currentSum - (count - i - 1);
                quotas[i] = rand.Next(1, maxPossible > 1 ? maxPossible : 2);
                currentSum += quotas[i];
            }
            quotas[count - 1] = total - currentSum;

            return quotas;
        }

        private void Producer(int id, int quota)
        {
            for (int i = 0; i < quota; i++)
            {
                emptySlots.WaitOne(); 
                mutex.WaitOne();     

                storage.Add($"Product {id}-{i}");
                Console.WriteLine($"Producer {id+1} added a product. In storage: {storage.Count}");

                mutex.Release();      
                порожнійСклад.Release(); 
            }
        }

        private void Consumer(int id, int quota)
        {
            for (int i = 0; i < quota; i++)
            {
                порожнійСклад.WaitOne();  
                mutex.WaitOne();     

                if (storage.Count > 0)
                {
                    string item = storage[0];
                    storage.RemoveAt(0);
                    Console.WriteLine($"Consumer {id+1} took {item}. Left: {storage.Count}");
                }

                mutex.Release();      
                emptySlots.Release(); 
            }
        }
    } 

}
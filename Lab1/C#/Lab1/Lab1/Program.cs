using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lab1
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Write quantity of threads:");
            int quantityOfThreads = int.Parse(Console.ReadLine());

            ThreadStopper threadStopper = new ThreadStopper();

            for (int i = 0; i < quantityOfThreads; i++)
            {
                ThreadCalculator threadCalculator = new ThreadCalculator(i+1, i+1);
                threadStopper.AddThread(threadCalculator);
                threadCalculator.Start();
            }

            threadStopper.Start();
        }
    }
}

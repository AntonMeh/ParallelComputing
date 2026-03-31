using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Lab2
{
    internal class Program
    {
        private static readonly int length = 100_000_000; 
        private static readonly int threadsCount = 16;
        private static int minNum = -172;
        private static int minIndex = 50000;
        private static readonly Stopwatch timer = new Stopwatch();

        static void Main(string[] args)
        {
            Console.WriteLine("Quantity of threads: " + threadsCount);

            GigArray gigArray = new GigArray(length, threadsCount, minNum, minIndex);
            gigArray.CreateArray();
            timer.Start();
            gigArray.FindMin();

            timer.Stop();
            Console.WriteLine("Time: " + timer.ElapsedMilliseconds + " ms");
        }
    }
}

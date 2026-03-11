using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Lab1
{
    internal class ThreadCalculator
    {
        public int id;
        private readonly Thread thread;
        private int step;

        private volatile bool isRunning = true;

        public ThreadCalculator(int id, int step)
        {
            this.id = id;
            this.step = step;
            thread = new Thread(Calculate);
        }
        public int Id { get { return id; } set { id = value; } }

        public void Start() => thread.Start();
        public void RequestStop() => isRunning = false;

        private void Calculate()
        {
            long sum = 0;
            int value = 0;
            do
            {
                sum += step;
                value++;

            } while (isRunning);
            Console.WriteLine($"Thread {id} finished\t sum = {sum}\t Quantity = {value}");
        }    
    }

    internal class ThreadStopper
    {
        private List<(ThreadCalculator calculator, int stopAfterMs)> scheduled = new List<(ThreadCalculator, int)>();
        private Thread controlThread;

        private static readonly Random rng = new Random();

        public ThreadStopper()
        {
            controlThread = new Thread(ControlLoop);
        }

        public void AddThread(ThreadCalculator tc)
        {
            int delay = rng.Next(2000, 10000); 
            scheduled.Add((tc, delay));
            Console.WriteLine($"Thread {tc.Id} will be stopped after {delay} ms");
        }

        private void ControlLoop()
        {
            var ordered = scheduled.OrderBy(x => x.stopAfterMs).ToList();

            int elapsed = 0;
            foreach (var entry in ordered)
            {
                int waitTime = entry.stopAfterMs - elapsed;
                Thread.Sleep(waitTime);
                elapsed += waitTime;

                entry.calculator.RequestStop();
                Console.WriteLine($"[Controller] Thread {entry.calculator.id} stop signal sent at {elapsed} ms");
            }
        }

        public void Start() => controlThread.Start();
    }
}

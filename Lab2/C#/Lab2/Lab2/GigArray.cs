using System;
using System.Threading;

namespace Lab2
{
    internal class GigArray
    {
        private readonly int length;
        private long[] array;
        private readonly Random random = new Random();
        private readonly Thread[] threads;
        private int threadsCount;
        private int minNum;
        private int minIndex;

        private long globalMin = long.MaxValue;
        private int globalMinIndex = -1;
        private readonly object lockForMin = new object();

        private int finishedThreads = 0;
        private readonly object lockForCount = new object();

        public GigArray(int length, int threadsCount, int minNum, int minIndex)
        {
            this.length = length;
            this.threadsCount = threadsCount;
            this.minNum = minNum;
            this.minIndex = minIndex;
            threads = new Thread[threadsCount];
            array = new long[length];
        }

        public void CreateArray()
        {
            for (int i = 0; i < array.Length; i++)
            {
                array[i] = random.Next(100, 100000);
            }
            array[minIndex] = minNum;
        }

        public void FindMin()
        {
            int chunkSize = length / threadsCount;

            for (int i = 0; i < threadsCount; i++)
            {
                int start = i * chunkSize;
                int end = (i == threadsCount - 1) ? length : start + chunkSize;

                threads[i] = new Thread(SearchMinThread); 
                //threads[i].Start(new Bound(start, end));
                threads[i].Start(new Int64());
            }

            lock (lockForCount)
            {
                while (finishedThreads < threadsCount)
                {
                    Monitor.Wait(lockForCount);
                }
            }

            Console.WriteLine($"Min number: {globalMin}, Index: {globalMinIndex}");
        }

        private void SearchMinThread(object param)
        {
            Bound bound = param as Bound;
            //if (param is Bound bound)
            {
            long localMin = array[bound.StartIndex];
                int localIndex = bound.StartIndex;

                for (int i = bound.StartIndex + 1; i < bound.FinishIndex; i++)
                {
                    if (array[i] < localMin)
                    {
                        localMin = array[i];
                        localIndex = i;
                    }
                }

                lock (lockForMin)
                {
                    if (localMin < globalMin)
                    {
                        globalMin = localMin;
                        globalMinIndex = localIndex;
                    }
                }

                lock (lockForCount)
                {
                    finishedThreads++;
                    Monitor.Pulse(lockForCount);
                }
            }
        }
    }

    internal class Bound
    {
        public int StartIndex { get; set; }
        public int FinishIndex { get; set; }

        public Bound(int start, int finish)
        {
            StartIndex = start;
            FinishIndex = finish;
        }
    }
}
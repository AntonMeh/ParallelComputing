namespace _2nd_Variant
{
    internal class Program
    {
        static void Main()
        {
            Table table = new Table();
            for (int i = 0; i < 5; i++) new Philosopher(i, table).Start();
        }
    }
    class Table
    {
        public SemaphoreSlim[] forks = new SemaphoreSlim[5];
        public SemaphoreSlim waiter = new SemaphoreSlim(4, 4);
        public Table()
        {
            for (int i = 0; i < 5; i++) forks[i] = new SemaphoreSlim(1, 1);
        }
        public void GetFork(int id) { forks[id].Wait(); }
        public void PutFork(int id) { forks[id].Release(); }
    }

    class Philosopher
    {
        private Table table;
        private int id, leftFork, rightFork;

        public Philosopher(int id, Table table)
        {
            this.id = id; this.table = table;
            this.rightFork = id;
            this.leftFork = (id + 1) % 5;
        }

        public void Start()
        {
            new Thread(Run).Start();
        }

        private void Run()
        {
            for (int i = 0; i < 10; i++)
            {
                Console.WriteLine($"Philosopher {id} is thinking {i + 1} times");

                table.waiter.Wait(); 
                table.GetFork(rightFork);
                table.GetFork(leftFork);

                Console.WriteLine($"Philosopher {id} is eating {i + 1} times");

                table.PutFork(leftFork);
                table.PutFork(rightFork);
                table.waiter.Release();
            }
        }
    }
}

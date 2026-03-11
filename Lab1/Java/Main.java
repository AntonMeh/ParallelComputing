import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Random;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Write quantity of threads:");
        
        int quantityOfThreads = scanner.nextInt();

        ThreadStopper threadStopper = new ThreadStopper();

        for (int i = 0; i < quantityOfThreads; i++) {
            ThreadCalculator threadCalculator = new ThreadCalculator(i + 1, i + 1);
            threadStopper.addThread(threadCalculator);
            threadCalculator.start();
        }

        threadStopper.start();
        
        scanner.close();
    }
}

class ThreadCalculator implements Runnable {
    private final int id;
    private final int step;
    private final Thread thread;
    private volatile boolean isRunning = true;

    public ThreadCalculator(int id, int step) {
        this.id = id;
        this.step = step;
        this.thread = new Thread(this);
    }

    public int getId() { return id; }

    public void start() { thread.start(); }

    public void requestStop() { isRunning = false; }

    @Override
    public void run() {
        long sum = 0;
        long count = 0; 

        while (isRunning) {
            sum += step;
            count++;
        }

        System.out.printf("Thread %d finished\t sum = %d\t Quantity = %d%n", id, sum, count);
    }
}

class ThreadStopper {
    private final List<int[]> scheduled = new ArrayList<>();       // [id, stopAfterMs]
    private final List<ThreadCalculator> calculators = new ArrayList<>();
    private final Thread controlThread;
    private static final Random rng = new Random();

    public ThreadStopper() {
        controlThread = new Thread(this::controlLoop);
    }

    public void addThread(ThreadCalculator tc) {
        int delay = rng.nextInt(1000, 10000); 
        calculators.add(tc);
        scheduled.add(new int[]{ tc.getId(), delay });
        System.out.printf("Thread %d will be stopped after %d ms%n", tc.getId(), delay);
    }

    private void controlLoop() {
        scheduled.sort(Comparator.comparingInt(x -> x[1]));

        int elapsed = 0;
        for (int[] entry : scheduled) {
            int waitTime = Math.max(0, entry[1] - elapsed);
            try {
                Thread.sleep(waitTime);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return;
            }
            elapsed += waitTime;

            calculators.stream()
                    .filter(tc -> tc.getId() == entry[0])
                    .findFirst()
                    .ifPresent(ThreadCalculator::requestStop);

            System.out.printf("[Controller] Thread %d stop signal sent at %d ms%n", entry[0], elapsed);
        }
    }

    public void start() { controlThread.start(); }
}



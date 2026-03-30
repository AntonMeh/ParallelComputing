package jva;

import java.util.Random;

public class GigArray {
    private final int length;
    private long[] array;
    private final int threadsCount;
    private final int minNum;
    private final int minIndex;

    private long globalMin = Long.MAX_VALUE;
    private int globalMinIndex = -1;
    private final Object lockForMin = new Object();

    private int finishedThreads = 0;
    private final Object lockForCount = new Object();

    public GigArray(int length, int threadsCount, int minNum, int minIndex) {
        this.length = length;
        this.threadsCount = threadsCount;
        this.minNum = minNum;
        this.minIndex = minIndex;
        this.array = new long[length];
    }

    public void createArray() {
        Random random = new Random();
        for (int i = 0; i < length; i++) {
            array[i] = random.nextInt(100000 - 100) + 100;
        }
        array[minIndex] = minNum;
    }

    public void findMinThreaded() throws InterruptedException {
        int chunkSize = length / threadsCount;

        for (int i = 0; i < threadsCount; i++) {
            int start = i * chunkSize;
            int end = (i == threadsCount - 1) ? length : start + chunkSize;

            SearchTask task = new SearchTask(new Bound(start, end));
            new Thread(task).start();
        }

        synchronized (lockForCount) {
            while (finishedThreads < threadsCount) {
                lockForCount.wait(); 
            }
        }

        System.out.println("Min number: " + globalMin + ", Index: " + globalMinIndex);
    }

    private class SearchTask implements Runnable {
        private final Bound bound;

        public SearchTask(Bound bound) {
            this.bound = bound;
        }

        @Override
        public void run() {
            long localMin = array[bound.startIndex];
            int localIndex = bound.startIndex;

            for (int i = bound.startIndex + 1; i < bound.finishIndex; i++) {
                if (array[i] < localMin) {
                    localMin = array[i];
                    localIndex = i;
                }
            }

            synchronized (lockForMin) {
                if (localMin < globalMin) {
                    globalMin = localMin;
                    globalMinIndex = localIndex;
                }
            }

            synchronized (lockForCount) {
                finishedThreads++;
                lockForCount.notifyAll(); 
            }
        }
    }

    private static class Bound {
        final int startIndex;
        final int finishIndex;

        Bound(int start, int finish) {
            this.startIndex = start;
            this.finishIndex = finish;
        }
    }
}
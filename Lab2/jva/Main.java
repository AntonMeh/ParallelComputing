package jva;

public class Main {
    public static void main(String[] args) throws InterruptedException {
        int length = 100_000_000;
        int threadsCount = 10;
        int minNum = -172;
        int minIndex = 5000000;

        System.out.println("Quantity of threads: " + threadsCount);
        GigArray gigArray = new GigArray(length, threadsCount, minNum, minIndex);
        
        gigArray.createArray();
        
        long startTime = System.currentTimeMillis();
        gigArray.findMinThreaded();
        long endTime = System.currentTimeMillis();
        
        System.out.println("Time: " + (endTime - startTime) + " ms");
    }
}


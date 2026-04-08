package jva;

import java.util.Random;

public class Main {
    public static void main(String[] args) {
        int storageSize = 10;
        int totalItems = 20;
        int prodCount = 1;
        int consCount = 10;

        Manager manager = new Manager(storageSize);
        System.out.println("Start. Storage capacity: " + storageSize + ", Total items: " + totalItems);

        int[] prodQuotas = distribute(prodCount, totalItems);
        for (int i = 0; i < prodCount; i++) {
            new Thread(new Producer(i, prodQuotas[i], manager)).start();
        }

        int[] consQuotas = distribute(consCount, totalItems);
        for (int i = 0; i < consCount; i++) {
            new Thread(new Consumer(i, consQuotas[i], manager)).start();
        }
    }

    private static int[] distribute(int count, int total) {
        Random rand = new Random();
        int[] quotas = new int[count];
        int sum = 0;
        for (int i = 0; i < count - 1; i++) {
            int max = total - sum - (count - i - 1);
            quotas[i] = rand.nextInt(max > 0 ? max : 1) + 1;
            sum += quotas[i];
        }
        quotas[count - 1] = total - sum;
        return quotas;
    }
}
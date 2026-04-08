package jva;

public class Consumer implements Runnable {
    private final int id;
    private final int itemNumbers; 
    private final Manager manager;

    public Consumer(int id, int itemNumbers, Manager manager) {
        this.id = id;
        this.itemNumbers = itemNumbers;
        this.manager = manager;
    }

    @Override
    public void run() {
        for (int i = 0; i < itemNumbers; i++) {
            try {
                manager.empty.acquire(); 
                manager.access.acquire();

                String item = manager.storage.remove(0);
                System.out.println("Consumer " + id + " took: " + item + " (Left: " + manager.storage.size() + ")");

                manager.access.release();
                manager.full.release(); 

            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        System.out.println("*** Consumer " + id + " finished his plan (" + itemNumbers + ") ***");
    }
}
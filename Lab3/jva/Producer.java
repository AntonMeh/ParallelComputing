package jva;

public class Producer implements Runnable {
    private final int id;
    private final int itemNumbers; // Індивідуальна квота
    private final Manager manager;

    public Producer(int id, int itemNumbers, Manager manager) {
        this.id = id;
        this.itemNumbers = itemNumbers;
        this.manager = manager;
    }

    @Override
    public void run() {
        for (int i = 0; i < itemNumbers; i++) {
            try {
                manager.full.acquire(); 
                manager.access.acquire();

                String item = "Item-" + id + "-" + i;
                manager.storage.add(item);
                System.out.println("Producer " + id + " added: " + item + " (Storage: " + manager.storage.size() + ")");

                manager.access.release();
                manager.empty.release(); 
                
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        System.out.println("--- Producer " + id + " finished his plan (" + itemNumbers + ") ---");
    }
}
public class Main {
    public static void main(String[] args) {
        Table table = new Table();

        for (int i = 0; i < 5; i++) {
            new Philosopher(i, table);
        }
    }
}
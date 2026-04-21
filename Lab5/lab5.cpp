#include <iostream>
#include <iomanip>
#include <climits>
#include "omp.h"

using namespace std;

const int ROWS = 4000;
const int COLS = 4000;

int matrix[ROWS][COLS];

void initMatrix() {
    for (int i = 0; i < ROWS; i++)
        for (int j = 0; j < COLS; j++)
            matrix[i][j] = (i * COLS + j) % 100 - 30; 

    for (int j = 0; j < COLS; j++)
        matrix[72][j] = -1000;
}

long long totalSum(int numThreads) {
    long long sum = 0;
    double t1 = omp_get_wtime();

    #pragma omp parallel for reduction(+:sum) num_threads(numThreads) 
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            sum += matrix[i][j];
        }
    }

    double t2 = omp_get_wtime();
    #pragma omp critical
    {
         cout << "  [sum] threads=" << numThreads
         << "  time=" << fixed << setprecision(6) << (t2 - t1) << "s"
         << "  result=" << sum << "\n";
    }
    return sum;
}

void minRowSum(int numThreads, int &outRow, long long &outMin) {
    outMin = LLONG_MAX;
    outRow = -1;

    double t1 = omp_get_wtime();

    #pragma omp parallel num_threads(numThreads)
    {
        long long localMin = LLONG_MAX;
        int localRow = -1;

        #pragma omp for 
        for (int i = 0; i < ROWS; i++) {
            long long rowSum = 0;
            for (int j = 0; j < COLS; j++)
                rowSum += matrix[i][j];

            if (rowSum < localMin) {
                localMin = rowSum;
                localRow = i;
            }
        }

        #pragma omp critical
        {
            if (localMin < outMin) {
                outMin = localMin;
                outRow = localRow;
            }
        }
    }

    double t2 = omp_get_wtime();
    cout << "  [min] threads=" << numThreads
         << "  time=" << fixed << setprecision(6) << (t2 - t1) << " s"
         << "  row=" << outRow << "  sum=" << outMin << "\n";
}

void runBoth(int numThreads) {
    cout << "\n--- Number of threads: " << numThreads << " ---\n";

    omp_set_nested(1);

    int    minRow = -1;
    long long minVal = 0;
    long long sumVal = 0;

    double t1 = omp_get_wtime();

    #pragma omp parallel sections num_threads(2)
    {
        #pragma omp section
        {
            sumVal = totalSum(numThreads);
        }

        #pragma omp section
        {
            minRowSum(numThreads, minRow, minVal);
        }
    }

    double t2 = omp_get_wtime();
    cout << "  Total sections time: " << fixed << setprecision(6) << (t2 - t1) << " s\n";
    cout << "  Summary: sum=" << sumVal
         << ", min row=" << minRow
         << ", min row sum=" << minVal << "\n";
}

int main() {
    initMatrix();

    int threadCounts[] = {1, 2, 4, 8};
    for (int tc : threadCounts) {
        runBoth(tc);
    }
        
    return 0;
}
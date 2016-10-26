#include <mpi.h>
#include <stdio.h>
int main() {
  printf("Hej hej\n");
  MPI_Init(0, 0);
  int myRank;
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);
  printf("myRank = %d\n", myRank);
  MPI_Finalize();
  return 0;
}

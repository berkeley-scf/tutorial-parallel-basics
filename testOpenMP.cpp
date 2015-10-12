#include <iostream>
using namespace std;

// compile with:  g++ -fopenmp testOpenMP.cpp -o testOpenMP 

int main(){
  int nReps = 20;
  double x[nReps];
  #pragma omp parallel for
  for (int i=0; i<nReps; i++){
    x[i] = 0.0;
    for (int j=0; j<1000000; j++){
      x[i] = x[i] + 1.0;
    }
    cout << i << ":" << x[i] << endl;
  }
  cout << "Done with correct code; starting buggy code." << endl;

  int k, l;
  #pragma omp parallel for
  for (k=0; k<nReps; k++){
    x[k] = 0.0;
    for (l=0; l<1000000; l++){
      x[l] = x[l] + 1.0;
    }
    cout << k << ":" << x[l] << endl;
  }

  return 0;
}

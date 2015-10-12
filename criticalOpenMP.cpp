#include <iostream>
#include <cstdlib> 
using namespace std;

// compile with:  g++ -fopenmp criticalOpenMP.cpp -o criticalOpenMP 

int main(){
  int i;
  int len = 1000;
  double vec[len];
  double sum = 0.0;
  for(i = 0; i < len; i++){
    vec[i] = rand();
    sum += vec[i];
  }

  cout << "True sum is " << sum << ".\n";

  sum = 0.0;
  #pragma omp parallel for private (i) shared (sum)
  for (i = 0; i < len; i++){
    #pragma omp critical
    sum += vec[i];
  }
  cout << "Sum with critical is " << sum << ".\n";

  sum = 0.0;
  #pragma omp parallel for private (i) shared (sum)
  for (i = 0; i < len; i++){
    sum += vec[i];
  }
  cout << "Sum without critical is " << sum << ".\n";
  
  return 0;
}

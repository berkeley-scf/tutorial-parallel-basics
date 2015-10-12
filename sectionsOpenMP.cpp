#include <iostream>
#include <omp.h>
using namespace std;

// compile with:  g++ -fopenmp sectionsOpenMP.cpp -o sectionsOpenMP 

int main(){
  
  #pragma omp parallel // starts a new team of threads
  {
    int myID = omp_get_thread_num();
    cout << "I'm the 0th chunk on thread " <<  myID <<  "." << endl;  // should get run by each thread

    #pragma omp barrier // if we include this, all the 0th reports should happen first

    #pragma omp sections // divides the team into sections 
    { 
      // everything herein is run only by a single thread
      #pragma omp section 
      {       cout << "I'm the 1st chunk on thread " << myID << "." << endl; }
      #pragma omp section 
      { 
        cout << "I'm the 2nd chunk on thread " << myID << "." << endl;
        cout << "I'm the 3rd chunk on thread " << myID << "." << endl;
      } 
      #pragma omp section 
      { cout << "I'm the 4th chunk on thread " << myID << "." << endl; }
    } // implied barrier
  }

  return 0;
}

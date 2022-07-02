# FastArrayOps
Ultra Fast Array Operations using AVX/AVX2 code on the arrays to find Min-Max values and Index of them.

### Overview

In programming, it's very common to use and deal with the arrays, especially numerical arrays, in some operations like sorting, finding minimum and maximum values and their array index. Also, in image processing routines it can be seen that finding the max-min locations of some values, such histograms, image pixel values and locations of them are very common tasks. So, considering multi repetations on arrays can be very time consuming and it wanted to be optimized. Here, we already know how to find min and max values iterating over the arrays to find the considered index and the considered value. Therefore, the problem invloves writing faster codes, especially working with large arrays, by using machine codes (SIMD codes AVX, AVX2, AVX512), parallelizm and multi-threading. Also, using generic routines may increase the productivity and decrease the coding effort. 

FastArrayOps uses the classical approach and SIMD-accelerated codes (from the project of Kareem Omar at https://github.com/komrad36) to find minimum and maximum values and their array index. Also, generic routines have been written to test different types of numeric types. Based on Kareem's SIMD code in C, object files were produced (by using ml64.exe in VS) and used in the library. Simply, four types of arrayOpfined have been implemented in FastArrayOpsAVX.pas file as below:

 type TClassicArrayMinFinder = class
 public
  class procedure ValueIndexOfMinimum<T>(const AValues: array of T; IndexOfMin: Integer; var MinVal);
 end;

 type TClassicArrayMaxFinder = class
 public
  class procedure ValueIndexOfMaximum<T>(const AValues: array of T; IndexOfMax: Integer; var MaxVal);
 end;

 type TArrayContainsValue = class
 public
  class Procedure ContainsValue<T>(const anArrayOf: Array of T; const TargetValue; var Result: Boolean);
 end;

 type TArrayMinFinder = class
 public
  class Procedure MinValue<T>(const anArrayOf: Array of T; var Result);
 end;

 type TArrayMaxFinder = class
 public
  class Procedure MaxValue<T>(const anArrayOf: Array of T; var Result);
 end;
 
TClassicArrayMinFinder and TClassicArrayMaxFinder uses classical approca to find min-min index and max-maxindex, respectively. The other classes are the ones with SIMD-accelerated routines. The project file contains some test routines and comparisons by SIMD-accelerated routines. Please, investigate the test results using the arrays with 10000000 elements as show below:

======================================================================================

Random number sets for 10000000 elements are producing...  --->  Random number sets are produced (in 290 ms)...

Test for FastContains AVX functions begins....
--------------------------------------------------------------------------------------------------

FastContains(Int8Array)   --> Found: TRUE (should be true), Time (ms): 0
FastContains(Int8Array)   --> Found: FALSE (should be false), Time (ms): 0

FastContains(Int32Array)  --> Found: TRUE (should be true), Time (ms): 1
FastContains(Int32Array)  --> Found: FALSE (should be false), Time (ms): 1

FastContains(Int64Array)  --> Found: TRUE (should be true), Time (ms): 2
FastContains(Int64Array)  --> Found: FALSE (should be false), Time (ms): 4

FastContains(DoubleArray) --> Found: TRUE (should be true), Time (ms): 0
FastContains(DoubleArray) --> Found: FALSE (should be false), Time (ms): 25


Test for FastFindAVX functions begins....
--------------------------------------------------------------------------------------------------
Test FastFind-int64  --> result: Found index: 4999999, should be: 4999999, Time (ms): 2
Found index: 18446744073709551615
Actually it should be not found(-1), Time (ms): 4
So, when it could not find the searched value, it returns high(type_of_value)
Here it returned high(uint64) which equals to: 18446744073709551615

Test FastFind-floatAVX  --> result: Found index: 4999999, should be: 4999999, Time (ms): 5
Found index: 18446744073709551615, actually it should be not found( here not found as to returned index), Time (ms): 7

FastFind(Int32Array)  --> Found Index: 4999999 real index: 4999999 Time (ms): 1
FastFind(Int32Array)  --> Found Index (being not found): 18446744073709551615 real index: [Should me MaxInt64]: 18446744073709551615 Time (ms): 1

FastFind(Int64Array)  --> Found Index: 4999999 real index: 4999999 Time (ms): 2
FastFind(Int64Array)  --> Found Index (being not found): 18446744073709551615 real index: [Should me MaxInt64]: 18446744073709551615 Time (ms): 4

FastFind(DoubleArray) --> Found Index: 4999999 real index: 4999999 Time (ms): 3
FastFind(DoubleArray) --> Found Index (being not found): 18446744073709551615 real index: [Should me MaxInt64]: 18446744073709551615 Time (ms): 4


Test for FastMin and FastMax AVX-AVX2 functions begins....
--------------------------------------------------------------------------------------------------
FastMin(Int32Array)  --> Found value: 1 at index: 0, Time (ms): 4
FastMax(Int32Array)  --> Found value: 10000000 at index: 9999999, Time (ms): 4

FastMin(Int64Array)  --> Found value: 1000001 at index: 0, Time (ms): 11
FastMax(Int64Array)  --> Found value: 11000000 at index: 9999999, Time (ms): 9

FastMin(FloatArray)  --> Found value:  1.10000002384186E+0000 at index: 0, Time (ms): 4
FastMax(FloatArray)  --> Found value:  1.00000000000000E+0007 at index: 9999999, Time (ms): 4

FastMin(DoubleArray) --> Found value:  1.10000000000000E+0000 at index: 0, Time (ms): 11
FastMax(DoubleArray) --> Found value:  1.00000001000000E+0007 at index: 9999999, Time (ms): 9

min8:1, max8:126
min16:1, max16:32766
min32:1, max32:10000000
min64:1000001, max64:11000000
minInt16 idx: 0, min16: 1, Time(ms): 6
maxInt16 idx: 0, max16: 32766, Time(ms): 5
minInt32 idx: 0, min32: 1, Time(ms): 7
maxInt32 idx: 0, max32: 10000000, Time(ms): 7
minInt64 idx: 0, min64: 1000001, Time(ms): 13
maxInt64 idx: 0, max64: 11000000, Time(ms): 11

Int64 contains 2000000: TRUE
FastContainsint64Arr(int64V=2000000) is : TRUE

Finished. Press any key to exit...

==========================================================================================

Considering the results, Delphi compiled routines with classical approach slightly slower than SIMD-accelerated routines but not so much different on a huge array. Please test comment on these routines. If you have faster routines please share. 



### Tests
Done

### Delphi
Forever.

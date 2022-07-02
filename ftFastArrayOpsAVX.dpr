program ftFastArrayOpsAVX;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  FastMM5,
  System.StartUpCopy,
  System.SysUtils,
  System.Classes,
  System.Types,
  system.Math,
  System.SyncObjs,
  System.Diagnostics,
  System.Generics.Collections,
  System.Generics.Defaults,
  FastArrayOpsAVX in 'FastArrayOpsAVX.pas',
  Generics.Operators in 'Generics.Operators.pas';

const dummy       = 0;        //Note: this for just pass in fastmin/fastmax functions, so it's meaningless but necesseray hahhh
const ArrayLength = 10000000;
var int8Arr     : Array[0..ArrayLength-1] of int8_t;
var int16Arr    : Array[0..ArrayLength-1] of int16_t;
var int32Arr    : Array[0..ArrayLength-1] of int32_t;
var int64Arr    : Array[0..ArrayLength-1] of int64_t;
var uint8Arr    : Array[0..ArrayLength-1] of uint8_t;
var uint16Arr   : Array[0..ArrayLength-1] of uint16_t;
var uint32Arr   : Array[0..ArrayLength-1] of uint32_t;
var uint64Arr   : Array[0..ArrayLength-1] of uint64_t;
var floatArr    : Array[0..ArrayLength-1] of float;
var doubleArr   : Array[0..ArrayLength-1] of double;
var resbool     : bool;
var resInt32    : UInt32_t;
var resUInt32   : UInt32_t;
var resUInt32Idx: UInt32_t;
var resUInt64   : UInt64_t;
var resFloat    : Float;
var resDouble   : Double;
var ST          : TStopWatch;



Procedure MakeRandomArraysForAll();
var
 i: Integer;
 pint8,   pint16,  pint32,  pint64 : Pointer;
 puint8, puint16, puint32, puint64 : Pointer;

begin
//  for i := 0 to ArrayLength-1 do int8Arr[i]  := Random(Byte.MaxValue);
//  for i := 0 to ArrayLength-1 do int16Arr[i] := Random(SmallInt.MaxValue);
//  for i := 0 to ArrayLength-1 do int32Arr[i] := Random(Integer.MaxValue);
//  for i := 0 to ArrayLength-1 do int64Arr[i] := Random(Int64.MaxValue);
//  for i := 0 to ArrayLength-1 do floatArr[i] := Random(10000000)  / 10000000;
//  for i := 0 to ArrayLength-1 do doubleArr[i]:= Random(100000000) / 10000000;
//
//  for i := 0 to ArrayLength-1 do uint8Arr[i]  := Random(Byte.MaxValue);
//  for i := 0 to ArrayLength-1 do uint16Arr[i] := Random(SmallInt.MaxValue);
//  for i := 0 to ArrayLength-1 do uint32Arr[i] := Random(Integer.MaxValue);
//  for i := 0 to ArrayLength-1 do uint64Arr[i] := Random(Int64.MaxValue);

 pint8  := @int8Arr[0];    pint16 := @int16Arr[0];    pint32 := @int32Arr[0];     pint64 := @int64Arr[0];
 puint8 := @uint8Arr[0];  puint16 := @uint16Arr[0];  puint32 := @uint32Arr[0];   puint64 := @uint64Arr[0];
 for i := 0 to ArrayLength-1 do begin
  PInt8_t(pint8)^     := 1+Random(ShortInt.MaxValue-1);  inc(PInt8_t(PInt8));
  PInt16_t(pint16)^   := 1+Random(SmallInt.MaxValue-1);  inc(PInt16_t(PInt16));
  PInt32_t(pint32)^   := 1+Random(Integer.MaxValue-1);   inc(PInt32_t(PInt32));
  PInt64_t(pint64)^   := 1+Random(Int64.MaxValue-1);     inc(PInt64_t(PInt64));

  PuInt8_t(puint8)^   := 1+Random(Byte.MaxValue-1);      inc(PuInt8_t(PuInt8));
  PuInt16_t(puint16)^ := 1+Random(Word.MaxValue-1);      inc(PuInt16_t(PuInt16));
  PuInt32_t(puint32)^ := 1+Random(Cardinal.MaxValue-1);  inc(PuInt32_t(PuInt32)); // UnSigned Integer (uint32)
  PuInt64_t(puint64)^ := 1+Random(UInt64.MaxValue-1);    inc(PuInt64_t(PuInt64));
 end;
end;

Procedure FillInt8Array(PInt8Array: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PInt8_t(PInt8Array)^  := (i+1);
  inc(PInt8_t(PInt8Array));
 end;
end;
Procedure FillUInt8Array(PUInt8Array: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PUInt8_t(PUInt8Array)^  := (i+1);
  inc(PUInt8_t(PUInt8Array));
 end;
end;

Procedure FillInt16Array(PInt16Array: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PInt16_t(PInt16Array)^  := (i+1);
  inc(PInt16_t(PInt16Array));
 end;
end;
Procedure FillUInt16Array(PUInt16Array: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PUInt16_t(PUInt16Array)^  := (i+1);
  inc(PUInt16_t(PUInt16Array));
 end;
end;

Procedure FillInt32Array(PInt32Array: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PInt32_t(PInt32Array)^  := (i+1);
  inc(PInt32_t(PInt32Array));
 end;
end;
Procedure FillUInt32Array(PUInt32Array: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PUInt32_t(PUInt32Array)^  := (i+1);
  inc(PUInt32_t(PUInt32Array));
 end;
end;

Procedure FillInt64Array(PInt64Array: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PInt64(PInt64Array)^  := (i+1)+1000000;
  inc(PInt64(PInt64Array));
 end;
end;
Procedure FillUInt64Array(PUInt64Array: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PUInt64(PUInt64Array)^  := (i+1);
  inc(PUInt64(PUInt64Array));
 end;
end;

Procedure FillFloatArray(PFloatArray: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PFloat(PFloatArray)^  := (i+1) + 0.10000000;
  inc(PFloat(PFloatArray));
 end;
end;

Procedure FillDoubleArray(PDoubleArray: Pointer; const n: Int32_t);
begin
 for var i: Integer := 0 to n-1 do begin
  PDouble(PDoubleArray)^  := (i+1) + 0.10000000;
  inc(PDouble(PDoubleArray));
 end;
end;

Procedure FastContainsRoutineTest();
var
 et       : Int64;    //elapsed time (ms)
 fSearch  : Integer;  //search value
 ind_int64: Integer;  //search value from this index --> ind_int64:= ArrayLength div 2 - 1;

begin
   ind_int64:= ArrayLength div 2 - 1;
   fSearch  := int8Arr[ind_int64];
   ST       := TStopwatch.StartNew;
   resbool  := FastContains( @int8Arr[0], UInt64(ArrayLength), int8_t(fSearch) );
   et       := ST.ElapsedMilliseconds;
   writeLn('FastContains(Int8Array)   --> Found: ', resbool, ' (should be true), Time (ms): ', et);
   ST       := TStopwatch.StartNew;
   resbool  := FastContains( @int8Arr[0], UInt64(ArrayLength), int8_t(0) );
   et       := ST.ElapsedMilliseconds;
   writeLn('FastContains(Int8Array)   --> Found: ', resbool, ' (should be false), Time (ms): ', et);
   writeln;

   fSearch  := int32Arr[ind_int64];
   ST       := TStopwatch.StartNew;
   resbool  := FastContains( @int32Arr[0], UInt64(ArrayLength), int32_t(fSearch) );
   et       := ST.ElapsedMilliseconds;
   writeLn('FastContains(Int32Array)  --> Found: ', resbool, ' (should be true), Time (ms): ', et);
   ST       := TStopwatch.StartNew;
   resbool  := FastContains( @int32Arr[0], UInt64(ArrayLength), int32_t(0) );   //not found in array
   et       := ST.ElapsedMilliseconds;
   writeLn('FastContains(Int32Array)  --> Found: ', resbool, ' (should be false), Time (ms): ', et);
   writeln;

   fSearch  := int64Arr[ind_int64];
   ST       := TStopwatch.StartNew;
   resbool  := FastContains( @int64Arr[0], UInt64(ArrayLength), int64_t(fSearch) );
   et       := ST.ElapsedMilliseconds;
   writeLn('FastContains(Int64Array)  --> Found: ', resbool, ' (should be true), Time (ms): ', et);
   ST       := TStopwatch.StartNew;
   resbool  := FastContains( @int64Arr[0], UInt64(ArrayLength), int64_t(ArrayLength+1) ); //not found in array
   et       := ST.ElapsedMilliseconds;
   writeLn('FastContains(Int64Array)  --> Found: ', resbool, ' (should be false), Time (ms): ', et);
   writeln;

   var doubleVl: Double;
   doubleVl := doubleArr[ind_int64];
   ST       := TStopwatch.StartNew;
   resbool  := FastContains( @doubleArr[0], UInt64(ArrayLength), double(doubleVl) );
   et       := ST.ElapsedMilliseconds;
   writeLn('FastContains(DoubleArray) --> Found: ', resbool, ' (should be true), Time (ms): ', et);
   ST       := TStopwatch.StartNew;
   resbool  := FastContains( @doubleArr[0], UInt64(ArrayLength), double(ArrayLength+1) ); //not found in array
   et       := ST.ElapsedMilliseconds;
   writeLn('FastContains(DoubleArray) --> Found: ', resbool, ' (should be false), Time (ms): ', et);
   writeln;

end;

Procedure FastFindRoutineTest();
var
 et       : Int64;    //elapsed time (ms)
 fSearch  : Integer;  //search value
 ind_int64: Integer;  //search value from this index --> ind_int64:= ArrayLength div 2 - 1;

begin
   ind_int64 := ArrayLength div 2 - 1;

   fSearch   := int32Arr[ind_int64];
   ST        := TStopwatch.StartNew;
   resUInt64 := FastFind((@int32Arr[0]), UInt64(ArrayLength), uint32_t(fSearch));
   et        := ST.ElapsedMilliseconds;
   writeLn('FastFind(Int32Array)  --> Found Index: ', resUInt64, ' real index: ', ind_int64, ' Time (ms): ', et);
   fSearch    := (ArrayLength+1);
   ST         := TStopwatch.StartNew;
   resUInt64  := FastFind((@int32Arr[0]), UInt64(ArrayLength), uint32_t(fSearch));
   et         := ST.ElapsedMilliseconds;
   writeLn('FastFind(Int32Array)  --> Found Index (being not found): ', resUInt64, ' real index: [Should me MaxInt64]: ', resUInt64.MaxValue, ' Time (ms): ', et);
   writeLn;

   fSearch   := int64Arr[ind_int64];
   ST        := TStopwatch.StartNew;
   resUInt64 := FastFind(@int64Arr[0], UInt64(ArrayLength), uint64_t(fSearch));
   et        := ST.ElapsedMilliseconds;
   writeLn('FastFind(Int64Array)  --> Found Index: ', resUInt64, ' real index: ', ind_int64, ' Time (ms): ', et);
   fSearch    := (ArrayLength+1);
   ST         := TStopwatch.StartNew;
   resUInt64  := FastFind(@int64Arr[0], UInt64(ArrayLength), uint64_t(fSearch));
   et         := ST.ElapsedMilliseconds;
   writeLn('FastFind(Int64Array)  --> Found Index (being not found): ', resUInt64, ' real index: [Should me MaxInt64]: ', UInt64.MaxValue, ' Time (ms): ', et);
   writeLn;

   var fSearchD: Double;
   doubleArr[ind_int64] := 1111111111;
   fSearchD   := doubleArr[ind_int64];
   ST         := TStopwatch.StartNew;
   resUInt64  := FastFind(@doubleArr[0], UInt64(ArrayLength), double(fSearchD));
   et         := ST.ElapsedMilliseconds;
   writeLn('FastFind(DoubleArray) --> Found Index: ', resUInt64, ' real index: ', ind_int64, ' Time (ms): ', et);
   fSearchD   := (ArrayLength+1);
   ST         := TStopwatch.StartNew;
   resUInt64  := FastFind(@doubleArr[0], UInt64(ArrayLength), double(fSearchD));
   et         := ST.ElapsedMilliseconds;
   writeLn('FastFind(DoubleArray) --> Found Index (being not found): ', resUInt64, ' real index: [Should me MaxInt64]: ', UInt64.MaxValue, ' Time (ms): ', et);
   writeLn;

end;

Procedure MaxMinRoutineTest();
var
 et: Int64;

begin
   ST           := TStopwatch.StartNew;
   resInt32     := FastMin(pint32_t(@int32Arr[0]), UInt32(ArrayLength), dummy);
   resUInt32Idx := FastMinIdx(pint32_t(@int32Arr[0]), UInt32(ArrayLength), dummy);
   et           := ST.ElapsedMilliseconds;
   writeLn('FastMin(Int32Array)  --> Found value: ', resInt32, ' at index: ', resUInt32Idx, ', Time (ms): ', et);

   ST          := TStopwatch.StartNew;
   resInt32    := FastMax(pint32_t(@int32Arr[0]), UInt32(ArrayLength), dummy);
   resUInt32Idx:= FastMaxIdx(pint32_t(@int32Arr[0]), UInt32(ArrayLength), dummy);
   et          := ST.ElapsedMilliseconds;
   writeLn('FastMax(Int32Array)  --> Found value: ', resInt32, ' at index: ', resUInt32Idx, ', Time (ms): ', et);
   writeLn;

   ST           := TStopwatch.StartNew;
   resUInt64    := FastMin(pint64_t(@int64Arr[0]), UInt32(ArrayLength), dummy);
   resUInt32Idx := FastMinIdx(pint64_t(@int64Arr[0]), UInt32(ArrayLength), dummy);
   et           := ST.ElapsedMilliseconds;
   writeLn('FastMin(Int64Array)  --> Found value: ', resUInt64, ' at index: ', resUInt32Idx, ', Time (ms): ', et);

   ST          := TStopwatch.StartNew;
   resUInt64   := FastMax(pint64_t(@int64Arr[0]), UInt32(ArrayLength), dummy);
   resUInt32Idx   := FastMaxIdx(pint64_t(@int64Arr[0]), UInt32(ArrayLength), dummy);
   et          := ST.ElapsedMilliseconds;
   writeLn('FastMax(Int64Array)  --> Found value: ', resUInt64, ' at index: ', resUInt32Idx, ', Time (ms): ', et);
   writeLn;

   ST           := TStopwatch.StartNew;
   resFloat     := FastMin(pfloat(@floatArr[0]), UInt32(ArrayLength), dummy);
   resUInt32Idx := FastMinIdx(pfloat(@floatarr[0]), UInt32(ArrayLength), dummy);
   et           := ST.ElapsedMilliseconds;
   writeLn('FastMin(FloatArray)  --> Found value: ', resFloat, ' at index: ', resUInt32Idx, ', Time (ms): ', et);

   ST          := TStopwatch.StartNew;
   resFloat    := FastMax(pfloat(@floatArr[0]), UInt32(ArrayLength), dummy);
   resUInt32Idx   := FastMaxIdx(pfloat(@floatArr[0]), UInt32(ArrayLength), dummy);
   et          := ST.ElapsedMilliseconds;
   writeLn('FastMax(FloatArray)  --> Found value: ', resFloat, ' at index: ', resUInt32Idx, ', Time (ms): ', et);
   writeLn;

   ST           := TStopwatch.StartNew;
   resDouble    := FastMin(pdouble(@doubleArr[0]), UInt32(ArrayLength), dummy);
   resUInt32Idx := FastMinIdx(pdouble(@doublearr[0]), UInt32(ArrayLength), dummy);
   et           := ST.ElapsedMilliseconds;
   writeLn('FastMin(DoubleArray) --> Found value: ', resDouble, ' at index: ', resUInt32Idx, ', Time (ms): ', et);

   ST          := TStopwatch.StartNew;
   resDouble    := FastMax(pdouble(@doubleArr[0]), UInt32(ArrayLength), dummy);
   resUInt32Idx   := FastMaxIdx(pdouble(@doubleArr[0]), UInt32(ArrayLength), dummy);
   et          := ST.ElapsedMilliseconds;
   writeLn('FastMax(DoubleArray) --> Found value: ', resDouble, ' at index: ', resUInt32Idx, ', Time (ms): ', et);
   writeLn;
end;



begin
  randomize;

  try

   write('Random number sets for ', ArrayLength, ' elements are producing...  --->  ');
//   for i := 0 to ArrayLength-1 do int8Arr[i]  := Random(Byte.MaxValue);
//   for i := 0 to ArrayLength-1 do int16Arr[i] := Random(SmallInt.MaxValue);
//   for i := 0 to ArrayLength-1 do int32Arr[i] := Random(Integer.MaxValue);
//   for i := 0 to ArrayLength-1 do int64Arr[i] := Random(Int64.MaxValue);
//   for i := 0 to ArrayLength-1 do floatArr[i] := Random(10000000)/10000000;
//   for i := 0 to ArrayLength-1 do doubleArr[i]:= Random(100000000)/10000000;
   ST      := TStopwatch.StartNew;
   MakeRandomArraysForAll;
   writeln('Random number sets are produced (in ', ST.ElapsedMilliseconds, ' ms)...');


   writeln;
   writeln('Test for FastContains AVX functions begins....');
   writeln('--------------------------------------------------------------------------------------------------');

   writeln;
   FastContainsRoutineTest();

   var ind_q_in8t: UInt64;
   var q_int8: int8_t := 127;

   var ind_int64 : integer;
   ind_int64     := ArrayLength div 2 - 1;


   writeln;
   writeln('Test for FastFindAVX functions begins....');
   writeln('--------------------------------------------------------------------------------------------------');
   write('Test FastFind-int64  --> result: ');
   ST                  := TStopwatch.StartNew;
   int64Arr[50-1]      := 0;
   int64Arr[ind_int64] := q_int8;
   resUInt64           := FastFind((@int64Arr[0]), UInt64(ArrayLength), uint64_t(q_int8));
   writeln('Found index: ', resUInt64, ', should be: ', ind_int64 , ', Time (ms): ', ST.ElapsedMilliseconds);
   int64Arr[ind_int64] := q_int8-2;
   ST                  := TStopwatch.StartNew;
   resUInt64 := FastFind((@int64Arr[0]), UInt64(ArrayLength), uint64_t(q_int8));
   writeln('Found index: ', resUInt64);
   writeln('Actually it should be not found(', -1 , '), Time (ms): ', ST.ElapsedMilliseconds);
   writeln('So, when it could not find the searched value, it returns high(type_of_value)');
   writeln('Here it returned high(uint64) which equals to: ', high(uint64));


   writeln;
   write('Test FastFind-floatAVX  --> result: ');
   ST                  := TStopwatch.StartNew;
   floatArr[50-1]      := 0;
   floatArr[ind_int64] := q_int8;
   resUInt64           := FastFind((@floatArr[0]), UInt64(ArrayLength), float(q_int8));
   writeln('Found index: ', resUInt64, ', should be: ', ind_int64 , ', Time (ms): ', ST.ElapsedMilliseconds);
   floatArr[ind_int64] := q_int8-2;
   ST                  := TStopwatch.StartNew;
   resUInt64 := FastFind((@floatArr[0]), UInt64(ArrayLength), float(q_int8));
   writeln('Found index: ', resUInt64, ', actually it should be not found( here not found as to returned index), Time (ms): ', ST.ElapsedMilliseconds);

   writeln;
   FastFindRoutineTest();


   writeln;
   writeln('Test for FastMin and FastMax AVX-AVX2 functions begins....');
   writeln('--------------------------------------------------------------------------------------------------');
   FillInt32Array(@int32Arr[0], ArrayLength);
   FillInt64Array(@int64Arr[0], ArrayLength);
   FillFloatArray(@floatArr[0], ArrayLength);
   FillDoubleArray(@doubleArr[0], ArrayLength);
   MaxMinRoutineTest();

   {
   //int32Arr[50-1]      := High(Int32);
   //int32Arr[51-1]      := -High(Int32);
   ST                  := TStopwatch.StartNew;
   resUInt32           := FastMin(pint32_t(@int32Arr[0]), UInt32(ArrayLength), dummy);
   write('FastMin-I32 --> Found value: ', resUInt32, ' at index: ');
   resUInt32           := FastMinIdx(pint32_t(@int32Arr[0]), UInt32(ArrayLength), dummy);
   writeln(resUInt32 , ', Time (ms): ', ST.ElapsedMilliseconds);

   resUInt32           := FastMax(pint32_t(@int32Arr[0]), UInt32(ArrayLength), dummy);
   write('FastMax-I32 --> Found value: ', resUInt32, ' at index: ');
   resUInt32           := FastMaxIdx(pint32_t(@int32Arr[0]), UInt32(ArrayLength), dummy);
   writeln(resUInt32 , ', Time (ms): ', ST.ElapsedMilliseconds);


   //int64Arr[ind_int64]    := High(Int64);
   //int32Arr[ind_int64-1]  := -High(Int64);
   ST                     := TStopwatch.StartNew;
   resUInt64              := FastMin(pint64_t(@int64Arr[0]), UInt32(ArrayLength), dummy);
   write('FastMin-I64 --> Found value: ', resUInt64, ' at index: ');
   resUInt32              := FastMinIdx(pint64_t(@int64Arr[0]), UInt32(ArrayLength), dummy);
   writeln(resUInt32 , ', Time (ms): ', ST.ElapsedMilliseconds);

   resUInt64              := FastMax(pint64_t(@int64Arr[0]), UInt32(ArrayLength), dummy);
   write('FastMax-I64 --> Found value: ', resUInt64, ' at index: ');
   resUInt32              := FastMaxIdx(pint64_t(@int64Arr[0]), UInt32(ArrayLength), dummy);
   writeln(resUInt32 , ', Time (ms): ', ST.ElapsedMilliseconds);

   }

   var int8V: int8_t;
   var int16V: int16_t;
   var int32V: int32_t;
   var int64V: int64_t;
   var floatV: float;
   var doubleV: double;


   writeln('TArray...Finder Tests begin............');
   writeln('--------------------------------------------------------------------------------------------------');
   ST := TStopwatch.StartNew;
   TArrayMinFinder.MinValue<int8_t>(int8Arr,   int8V);  write('min8     : ',      int8V:12);
   TArrayMaxFinder.MaxValue<int8_t>(int8Arr,   int8V);  writeln(', max8:',  int8V:12, ', et(ms): ', ST.ElapsedMilliseconds);

   ST := TStopwatch.StartNew;
   TArrayMinFinder.MinValue<int16_t>(int16Arr, int16V); write('min16    : ',     int16V:12);
   TArrayMaxFinder.MaxValue<int16_t>(int16Arr, int16V); writeln(', max16:', int16V:12, ', et(ms): ', ST.ElapsedMilliseconds);

   ST := TStopwatch.StartNew;
   TArrayMinFinder.MinValue<int32_t>(int32Arr, int32V); write('min32    : ',     int32V:12);
   TArrayMaxFinder.MaxValue<int32_t>(int32Arr, int32V); writeln(', max32:', int32V:12, ', et(ms): ', ST.ElapsedMilliseconds);

   ST := TStopwatch.StartNew;
   TArrayMinFinder.MinValue<int64_t>(int64Arr, int64V); write('min64    : ', int64V:12);
   TArrayMaxFinder.MaxValue<int64_t>(int64Arr, int64V); writeln(', max64:',  int64V:12, ', et(ms): ', ST.ElapsedMilliseconds);

   ST := TStopwatch.StartNew;
   TArrayMinFinder.MinValue<float>(floatArr, floatV); write('minFloat :',   floatV:13);
   TArrayMaxFinder.MaxValue<float>(floatArr, floatV); writeln(', maxFloat :', floatV:13, ', et(ms): ', ST.ElapsedMilliseconds);

   ST := TStopwatch.StartNew;
   TArrayMinFinder.MinValue<double>(doubleArr, doubleV); write('minDouble:',     doubleV:13);
   TArrayMaxFinder.MaxValue<double>(doubleArr, doubleV); writeln(', maxDouble:', doubleV:13, ', et(ms): ', ST.ElapsedMilliseconds);

   writeln('--------------------------------------------------------------------------------------------------');
   writeLn;

   writeln('TClassicArray...Finder Tests begin............');
   writeln('--------------------------------------------------------------------------------------------------');
   var idx: Integer;

   ST                  := TStopwatch.StartNew;
   TClassicArrayMinFinder.ValueIndexOfMinimum<int16_t>(int16Arr, idx, int16V);
   writeln('minInt16 idx: ', idx, ', min16: ', int16V, ', Time(ms): ', ST.ElapsedMilliseconds);
   ST                  := TStopwatch.StartNew;
   TClassicArrayMaxFinder.ValueIndexOfMaximum<int16_t>(int16Arr, idx, int16V);
   writeln('maxInt16 idx: ', idx, ', max16: ', int16V, ', Time(ms): ', ST.ElapsedMilliseconds);

   ST                  := TStopwatch.StartNew;
   TClassicArrayMinFinder.ValueIndexOfMinimum<int32_t>(int32Arr, idx, int32V);
   writeln('minInt32 idx: ', idx, ', min32: ', int32V, ', Time(ms): ', ST.ElapsedMilliseconds);
   ST                  := TStopwatch.StartNew;
   TClassicArrayMaxFinder.ValueIndexOfMaximum<int32_t>(int32Arr, idx, int32V);
   writeln('maxInt32 idx: ', idx, ', max32: ', int32V, ', Time(ms): ', ST.ElapsedMilliseconds);

   ST                  := TStopwatch.StartNew;
   TClassicArrayMinFinder.ValueIndexOfMinimum<int64_t>(int64Arr, idx, int64V);
   writeln('minInt64 idx: ', idx, ', min64: ', int64V, ', Time(ms): ', ST.ElapsedMilliseconds);
   ST                  := TStopwatch.StartNew;
   TClassicArrayMaxFinder.ValueIndexOfMaximum<int64_t>(int64Arr, idx, int64V);
   writeln('maxInt64 idx: ', idx, ', max64: ', int64V, ', Time(ms): ', ST.ElapsedMilliseconds);

   ST                  := TStopwatch.StartNew;
   TClassicArrayMinFinder.ValueIndexOfMinimum<float>(floatArr, idx, floatV);
   writeln('floatV idx: ', idx, ', min: ', floatV, ', Time(ms): ', ST.ElapsedMilliseconds);
   ST                  := TStopwatch.StartNew;
   TClassicArrayMaxFinder.ValueIndexOfMaximum<float>(floatArr, idx, floatV);
   writeln('floatV idx: ', idx, ', max: ', floatV, ', Time(ms): ', ST.ElapsedMilliseconds);

   ST                  := TStopwatch.StartNew;
   TClassicArrayMinFinder.ValueIndexOfMinimum<double>(doubleArr, idx, doubleV);
   writeln('doubleV idx: ', idx, ', min: ', doubleV, ', Time(ms): ', ST.ElapsedMilliseconds);
   ST                  := TStopwatch.StartNew;
   TClassicArrayMaxFinder.ValueIndexOfMaximum<double>(doubleArr, idx, doubleV);
   writeln('doubleV idx: ', idx, ', max: ', doubleV, ', Time(ms): ', ST.ElapsedMilliseconds);
   writeln('--------------------------------------------------------------------------------------------------');



   ST := TStopwatch.StartNew;
   int32V := int32_t(TGenericMinMax.Min<int32_t>(int32Arr, TComparer<int32>.Construct(
    function(const Left,Right: integer): int32_t
    begin
     Result := Left-Right
    end)));
   writeln('Generic comparer minInt32: ', int32V:9, ', Time(ms): ', ST.ElapsedMilliseconds:4);

   ST := TStopwatch.StartNew;
   int32V := int32_t(TGenericMinMax.Max<int32_t>(int32Arr, TComparer<int32>.Construct(
    function(const Left,Right: integer): int32_t
    begin
     Result := Left-Right
    end)));
   writeln('Generic comparer maxInt32: ', int32V:9, ', Time(ms): ', ST.ElapsedMilliseconds:4);

   var boolRes: Boolean;
   int64V := 2000000;
   writeln;
   TArrayContainsValue.ContainsValue<int64_t>(int64Arr, int64V, boolRes); writeln('Int64 contains ', int64V, ': ', boolRes);

   writeLn('FastContainsint64Arr(int64V=', int64V, ') is : ', FastContains(pint64_t(@int64Arr[0]), ArrayLength, int64V));

   writeln;
   write('Finished. Press any key to exit...');
   readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

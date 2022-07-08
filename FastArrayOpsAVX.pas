{******************************************************************************}
{                                                                              }
{                           FastArrayOps Library                               }
{                                                                              }
{ The actual proje motivating project is at https://github.com/komrad36        }
{ by Kareem Omar. Is's SIMD-accelerated (AVX, AVX2) routines in MacroAssembly  }
{                                                                              }
{ This is a Delphi port of Kareem's project (in C) by adding generics suppot to}
{ Delphi users and lovers.                                                     }
{                                                                              }
{ Copyright (c) 2022 Dr. Fatih Taþpýnar, fatihtsp@gmail.com                    }
{ All rights reserved.                                                         }
{                                                                              }
{ Date: 27.06.2022                                                             }
{                                                                              }
{ Notes:                                                                       }
{ Ultra fast avx/avx2 based array max, min, and index finding routines.        }
{ All the routines works well and really fast. Compared with the classically   }
{ coded routine,  sometimes AVX based routine are slightly faster.             }
{ I've tested on Intel i7-10875H CPU-32GB Ram on Win11 and OS is running via   }
{ high ower mode enabled  with battery charger plugged-in...                   }
{ Test it and share your findings...                                           }
{ Also, if you have faster codes you can share                                 }
{                                                                              }
{******************************************************************************}


unit FastArrayOpsAVX;

interface

uses
 System.SysUtils, System.Classes, System.Win.Crtl, System.Math,
 System.SyncObjs, System.Diagnostics,
 System.TypInfo,
 System.Generics.Collections,
 System.Generics.Defaults
 //Rapid.Generics
 ;

{$Z4}

{.$I ..\Definitions.inc}

{.$define UNDERSCOREIMPORTNAME}

const
{$IFDEF UNDERSCOREIMPORTNAME}
  _PU = '_';
{$ELSE}
  _PU = '';
{$ENDIF}


type
  {$REGION 'C types'}

  bool       = System.Boolean;
  {$IF CompilerVersion < 31}
  char       = System.AnsiChar;
  {$ELSE}
  char       = System.UTF8Char;
  {$ENDIF}
  char16_t   = System.Char;
  double     = System.Double;
  float      = System.Single;
  int16_t    = System.SmallInt;
  int32_t    = System.Integer;
  int64_t    = System.Int64;
  int8_t     = System.ShortInt;
  intptr_t   = System.NativeInt;
  long       = System.LongInt;
  size_t     = System.NativeUInt;
  uint16_t   = System.Word;
  uint32_t   = System.Cardinal;
  uint64_t   = System.UInt64;
  uint8_t    = System.Byte;
  uintptr_t  = System.NativeUInt;

  pbool      = ^bool;
  pchar      = ^char;
  pchar16_t  = ^char16_t;
  pdouble    = ^double;
  pfloat     = ^float;
  pint16_t   = ^int16_t;
  pint32_t   = ^int32_t;
  pint64_t   = ^int64_t;
  pint8_t    = ^int8_t;
  pintptr_t  = ^intptr_t;
  plong      = ^long;
  psize_t    = ^size_t;
  puint16_t  = ^uint16_t;
  puint32_t  = ^uint32_t;
  puint64_t  = ^uint64_t;
  puint8_t   = ^uint8_t;
  puintptr_t = ^uintptr_t;

  {$ENDREGION}

 type TClassicArrayMinFinder = class
 public
  class procedure ValueIndexOfMinimum<T>(const AValues: array of T; var IndexOfMin: Integer; var MinVal);
 end;

 type TClassicArrayMaxFinder = class
 public
  class procedure ValueIndexOfMaximum<T>(const AValues: array of T; var IndexOfMax: Integer; var MaxVal);
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


type
 TGenericMinMax = class
 class function Min<T>(const values: array of T; const Comparer: IComparer<T>): T;
 class function Max<T>(const values: array of T; const Comparer: IComparer<T>): T;
end;



//extern "C" bool FastContains8(const void* p, uint64_t n, uint8_t q);
function FastContains8(dest: Pointer; n: uint64_t; q: uint8_t): bool; cdecl; external name _PU + 'FastContains8';

//extern "C" bool FastContains16(const void* p, uint64_t n, uint16_t q);
function FastContains16(dest: Pointer; n: uint64_t; q: uint16_t): bool; cdecl; external name _PU + 'FastContains16';

//extern "C" bool FastContains32(const void* p, uint64_t n, uint32_t q);
function FastContains32(dest: Pointer; n: uint64_t; q: uint32_t): bool; cdecl; external name _PU + 'FastContains32';

//extern "C" bool FastContains64(const void* p, uint64_t n, uint64_t q);
function FastContains64(dest: Pointer; n: uint64_t; q: uint64_t): bool; cdecl; external name _PU + 'FastContains64';

//extern "C" bool FastContainsFloat(const float* p, uint64_t n, float q);
function FastContainsFloat(dest: Pfloat; n: uint64_t; q: float): bool; cdecl; external name _PU + 'FastContainsFloat';

//extern "C" bool FastContainsDouble(const double* p, uint64_t n, double q);
function FastContainsDouble(dest: Pdouble; n: uint64_t; q: double): bool; cdecl; external name _PU + 'FastContainsDouble';


//extern "C" uint64_t FastFind8(const void* p, uint64_t n, uint8_t q);
function FastFind8(dest: pointer; n: uint64_t; q: uint8_t): uint64_t; cdecl; external name _PU + 'FastFind8';

//extern "C" uint64_t FastFind16(const void* p, uint64_t n, uint16_t q);
function FastFind16(dest: pointer; n: uint64_t; q: uint16_t): uint64_t; cdecl; external name _PU + 'FastFind16';

//extern "C" uint64_t FastFind32(const void* p, uint64_t n, uint32_t q);
function FastFind32(dest: pointer; n: uint64_t; q: uint32_t): uint64_t; cdecl; external name _PU + 'FastFind32';

//extern "C" uint64_t FastFind64(const void* p, uint64_t n, uint64_t q);
function FastFind64(dest: pointer; n: uint64_t; q: uint64_t): uint64_t; cdecl; external name _PU + 'FastFind64';

//extern "C" uint64_t FastFindFloat(const float* p, uint64_t n, float q);
function FastFindFloat(dest: Pfloat; n: uint64_t; q: float): uint64_t; cdecl; external name _PU + 'FastFindFloat';

//extern "C" uint64_t FastFindDouble(const double* p, uint64_t n, double q);
function FastFindDouble(dest: Pdouble; n: uint64_t; q: double): uint64_t; cdecl; external name _PU + 'FastFindDouble';


////////////////////////////////////////////////////////////////////////////////
function FastContains(const p: pint8_t; n: uint64_t; q: int8_t ):bool; inline; overload;
function FastContains(const p: puint8_t; n: uint64_t; q: uint8_t ):bool; inline; overload;
Function FastContains(const p: pint16_t; n: uint64_t; q: int16_t ):bool; inline; overload;
Function FastContains(const p:puint16_t; n: uint64_t; q: uint16_t):bool; inline; overload;
Function FastContains(const p:pint32_t; n:uint64_t; q:int32_t):bool; inline; overload;
Function FastContains(const p:puint32_t; n: uint64_t; q: uint32_t):bool; inline; overload;
Function FastContains(const p:pint64_t; n: uint64_t; q: int64_t):bool; inline; overload;
Function FastContains(const p:puint64_t; n: uint64_t; q: uint64_t):bool; inline; overload;
Function FastContains(const p:Pfloat; n: uint64_t; q: float):bool; inline; overload;
Function FastContains(const p:pdouble; n: uint64_t; q: double):bool; inline; overload;

////////////////////////////////////////////////////////////////////////////////

Function FastFind(const p: pint8_t; n: uint64_t; q: int8_t): uint64_t; inline; overload;
Function FastFind(const p: puint8_t; n: uint64_t; q: uint8_t): uint64_t; inline; overload;
Function FastFind(const p: pint16_t; n: uint64_t; q: int16_t): uint64_t; inline; overload;
Function FastFind(const p: puint16_t; n: uint64_t; q: uint16_t ): uint64_t; inline; overload;
Function FastFind(const p: pint32_t; n: uint64_t; q: int32_t): uint64_t; inline; overload;
Function FastFind(const p: puint32_t; n: uint64_t; q: uint32_t): uint64_t; inline; overload;
Function FastFind(const p: pint64_t; n: uint64_t; q: int64_t): uint64_t; inline; overload;
Function FastFind(const p: puint64_t; n: uint64_t; q: uint64_t): uint64_t; inline; overload;
Function FastFind(const p: pfloat; n: uint64_t; q: float): uint64_t; inline; overload;
Function FastFind(const p: pdouble; n: uint64_t; q: double): uint64_t; inline; overload;


////////////////////////////////////////////////////////////////////////////////
//extern "C" float FastMinFloat(const float* p, uint32_t n);
Function FastMinFloat(const p: pfloat; n: uint32_t): float; cdecl; external name _PU + 'FastMinFloat';
//extern "C" uint32_t FastMinIdxFloat(const float* p, uint32_t n);
Function FastMinIdxFloat(const p: pfloat; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxFloat';

//extern "C" double FastMinDouble(const double* p, uint32_t n);
Function FastMinDouble(const p: pdouble; n: uint32_t): double; cdecl; external name _PU + 'FastMinDouble';
//extern "C" uint32_t FastMinIdxDouble(const double* p, uint32_t n);
Function FastMinIdxDouble(const p: pdouble; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxDouble';

//extern "C" int8_t FastMinI8(const int8_t* p, uint32_t n);
Function FastMinI8(const p: pint8_t; n: uint32_t): int8_t; cdecl; external name _PU + 'FastMinI8';
//extern "C" uint32_t FastMinIdxI8(const int8_t* p, uint32_t n);
Function FastMinIdxI8(const p: pint8_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxI8';

//extern "C" int16_t FastMinI16(const int16_t* p, uint32_t n);
Function FastMinI16(const p: pint16_t; n: uint32_t): int16_t; cdecl; external name _PU + 'FastMinI16';
//extern "C" uint32_t FastMinIdxI16(const int16_t* p, uint32_t n);
Function FastMinIdxI16(const p: pint16_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxI16';

//extern "C" int32_t FastMinI32(const int32_t* p, uint32_t n);
Function FastMinI32(const p: pint32_t; n: uint32_t): int32_t; cdecl; external name _PU + 'FastMinI32';
//extern "C" uint32_t FastMinIdxI32(const int32_t* p, uint32_t n);
Function FastMinIdxI32(const p: pint32_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxI32';

//extern "C" int64_t FastMinI64(const int64_t* p, uint32_t n);
Function FastMinI64(const p: pint64_t; n: uint32_t): int64_t; cdecl; external name _PU + 'FastMinI64';
//extern "C" uint32_t FastMinIdxI64(const int64_t* p, uint32_t n);
Function FastMinIdxI64(const p: pint64_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxI64';

//extern "C" uint8_t FastMinU8(const uint8_t* p, uint32_t n);
Function FastMinU8(const p: puint8_t; n: uint32_t): uint8_t; cdecl; external name _PU + 'FastMinU8';
//extern "C" uint32_t FastMinIdxU8(const uint8_t* p, uint32_t n);
Function FastMinIdxU8(const p: puint8_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxU8';

//extern "C" uint16_t FastMinU16(const uint16_t* p, uint32_t n);
Function FastMinU16(const p: puint16_t; n: uint32_t): uint16_t; cdecl; external name _PU + 'FastMinU16';
//extern "C" uint32_t FastMinIdxU16(const uint16_t* p, uint32_t n);
Function FastMinIdxU16(const p: puint16_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxU16';

//extern "C" uint32_t FastMinU32(const uint32_t* p, uint32_t n);
Function FastMinU32(const p: puint32_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinU32';
//extern "C" uint32_t FastMinIdxU32(const uint32_t* p, uint32_t n);
Function FastMinIdxU32(const p: puint32_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxU32';

//extern "C" uint64_t FastMinU64(const uint64_t* p, uint32_t n);
Function FastMinU64(const p: puint64_t; n: uint32_t): uint64_t; cdecl; external name _PU + 'FastMinU64';
//extern "C" uint32_t FastMinIdxU64(const uint64_t* p, uint32_t n);
Function FastMinIdxU64(const p: puint64_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMinIdxU64';

//extern "C" float FastMaxFloat(const float* p, uint32_t n);
Function FastMaxFloat(const p: pfloat; n: uint32_t): float; cdecl; external name _PU + 'FastMaxFloat';
//extern "C" uint32_t FastMaxIdxFloat(const float* p, uint32_t n);
Function FastMaxIdxFloat(const p: pfloat; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxFloat';

//extern "C" double FastMaxDouble(const double* p, uint32_t n);
Function FastMaxDouble(const p: pdouble; n: uint32_t): double; cdecl; external name _PU + 'FastMaxDouble';
//extern "C" uint32_t FastMaxIdxDouble(const double* p, uint32_t n);
Function FastMaxIdxDouble(const p: pdouble; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxDouble';
//
//extern "C" int8_t FastMaxI8(const int8_t* p, uint32_t n);
Function FastMaxI8(const p: pint8_t; n: uint32_t): int8_t; cdecl; external name _PU + 'FastMaxI8';
//extern "C" uint32_t FastMaxIdxI8(const int8_t* p, uint32_t n);
Function FastMaxIdxI8(const p: pint8_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxI8';

//extern "C" int16_t FastMaxI16(const int16_t* p, uint32_t n);
Function FastMaxI16(const p: pint16_t; n: uint32_t): int16_t; cdecl; external name _PU + 'FastMaxI16';
//extern "C" uint32_t FastMaxIdxI16(const int16_t* p, uint32_t n);
Function FastMaxIdxI16(const p: pint16_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxI16';

//extern "C" int32_t FastMaxI32(const int32_t* p, uint32_t n);
Function FastMaxI32(const p: pint32_t; n: uint32_t): int32_t; cdecl; external name _PU + 'FastMaxI32';
//extern "C" uint32_t FastMaxIdxI32(const int32_t* p, uint32_t n);
Function FastMaxIdxI32(const p: pint32_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxI32';

//extern "C" int64_t FastMaxI64(const int64_t* p, uint32_t n);
Function FastMaxI64(const p: pint64_t; n: uint32_t): int64_t; cdecl; external name _PU + 'FastMaxI64';
//extern "C" uint32_t FastMaxIdxI64(const int64_t* p, uint32_t n);
Function FastMaxIdxI64(const p: pint64_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxI64';

//extern "C" uint8_t FastMaxU8(const uint8_t* p, uint32_t n);
Function FastMaxU8(const p: puint8_t; n: uint32_t): uint8_t; cdecl; external name _PU + 'FastMaxU8';
//extern "C" uint32_t FastMaxIdxU8(const uint8_t* p, uint32_t n);
Function FastMaxIdxU8(const p: puint8_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxU8';

//extern "C" uint16_t FastMaxU16(const uint16_t* p, uint32_t n);
Function FastMaxU16(const p: puint16_t; n: uint32_t): uint16_t; cdecl; external name _PU + 'FastMaxU16';
//extern "C" uint32_t FastMaxIdxU16(const uint16_t* p, uint32_t n);
Function FastMaxIdxU16(const p: puint16_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxU16';

//extern "C" uint32_t FastMaxU32(const uint32_t* p, uint32_t n);
Function FastMaxU32(const p: puint32_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxU32';
//extern "C" uint32_t FastMaxIdxU32(const uint32_t* p, uint32_t n);
Function FastMaxIdxU32(const p: puint32_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxU32';

//extern "C" uint64_t FastMaxU64(const uint64_t* p, uint32_t n);
Function FastMaxU64(const p: puint64_t; n: uint32_t): uint64_t; cdecl; external name _PU + 'FastMaxU64';
//extern "C" uint32_t FastMaxIdxU64(const uint64_t* p, uint32_t n);
Function FastMaxIdxU64(const p: puint64_t; n: uint32_t): uint32_t; cdecl; external name _PU + 'FastMaxIdxU64';


Function FastMin( const p: pfloat; n: uint32_t; dummy:float=0 ): float;  inline; overload;

Function FastMinIdx(const p: pfloat; n: uint32_t; dummy:float=0  ): uint32_t; inline; overload;

Function FastMin(const p: pdouble; n: uint32_t; dummy:double=0  ): double; inline; overload;

Function FastMinIdx(const p: pdouble; n: uint32_t; dummy:double=0  ): uint32_t; inline; overload;

Function FastMin(const p: pint8_t; n: uint32_t; dummy:int8_t=0 ): int8_t; inline; overload;

Function FastMinIdx(const p: pint8_t; n: uint32_t; dummy:int8_t=0): uint32_t; inline; overload;

Function FastMin(const p: pint16_t; n: uint32_t; dummy:int16_t=0 ): int16_t; inline; overload;

Function FastMinIdx(const p: pint16_t; n: uint32_t; dummy:int16_t=0):uint32_t; inline; overload;

Function FastMin(const p: pint32_t; n: uint32_t; dummy:int32_t=0 ): int32_t; inline; overload;

Function FastMinIdx(const p: pint32_t; n: uint32_t; dummy:int32_t=0): uint32_t; inline; overload;

Function FastMin(const p: pint64_t; n: uint32_t; dummy:int64_t=0 ): int64_t; inline; overload;

Function FastMinIdx(const p: pint64_t; n: uint32_t; dummy:int64_t=0): uint32_t; inline; overload;

Function FastMin(const p: puint8_t; n: uint32_t; dummy:uint8_t=0 ): uint8_t; inline; overload;

Function FastMinIdx(const p: puint8_t; n: uint32_t; dummy:uint8_t=0): uint32_t; inline; overload;

Function FastMin(const p: puint16_t; n: uint32_t; dummy:uint16_t=0 ): uint16_t; inline; overload;

Function FastMinIdx(const p: puint16_t; n: uint32_t; dummy:uint16_t=0): uint32_t; inline; overload;

Function FastMin(const p: puint32_t; n: uint32_t; dummy:uint32_t=0 ): uint32_t; inline; overload;

Function FastMinIdx(const p: puint32_t; n: uint32_t; dummy:uint32_t=0): uint32_t; inline; overload;

Function FastMin(const p: puint64_t; n: uint32_t; dummy:uint64_t=0 ): uint64_t; inline; overload;

Function FastMinIdx(const p: puint64_t; n: uint32_t; dummy:uint64_t=0 ): uint32_t; inline; overload;

////////////////////////////////////////////////////////////////////////////////

Function FastMax(const p: pfloat; n: uint32_t; dummy:float=0): float; inline; overload;

Function FastMaxIdx(const p: pfloat; n: uint32_t; dummy:float=0): uint32_t; inline; overload;

Function FastMax(const p: pdouble; n: uint32_t; dummy:double=0): double; inline; overload;

Function FastMaxIdx(const p: pdouble; n: uint32_t; dummy:double=0): uint32_t; inline; overload;

Function FastMax(const p:pint8_t; n: uint32_t; dummy:int8_t=0): int8_t; inline; overload;

Function FastMaxIdx(const p:pint8_t; n: uint32_t; dummy:int8_t=0): uint32_t; inline; overload;

Function FastMax(const p:pint16_t; n: uint32_t; dummy:int16_t=0): int16_t; inline; overload;

Function FastMaxIdx(const p:pint16_t; n: uint32_t; dummy:int16_t=0): uint32_t; inline; overload;

Function FastMax(const p:pint32_t; n: uint32_t; dummy:int32_t=0): int32_t; inline; overload;

Function FastMaxIdx(const p:pint32_t; n: uint32_t; dummy:int32_t=0): uint32_t; inline; overload;

Function FastMax(const p:pint64_t; n: uint32_t; dummy:int64_t=0): int64_t; inline; overload;

Function FastMaxIdx(const p:pint64_t; n: uint32_t; dummy:int64_t=0): uint32_t; inline; overload;

Function FastMax(const p:puint8_t; n: uint32_t; dummy:uint8_t=0): uint8_t; inline; overload;

Function FastMaxIdx(const p:puint8_t; n: uint32_t; dummy:uint8_t=0): uint32_t; inline; overload;

Function FastMax(const p:puint16_t; n: uint32_t; dummy:uint16_t=0): uint16_t; inline; overload;

Function FastMaxIdx(const p:puint16_t; n: uint32_t; dummy:uint16_t=0): uint32_t; inline; overload;

Function FastMax(const p:puint32_t; n: uint32_t; dummy:uint32_t=0): uint32_t; inline; overload;

Function FastMaxIdx(const p:puint32_t; n: uint32_t; dummy:uint32_t=0): uint32_t; inline; overload;

Function FastMax(const p:puint64_t; n: uint32_t; dummy:uint64_t=0): uint64_t; inline; overload;

Function FastMaxIdx(const p:puint64_t; n: uint32_t; dummy:uint64_t=0): uint32_t ; inline; overload;



implementation

 // Only for Win64 and Win32 won't be used...
 {$ifdef WIN64}
  {$L asm\objs_X64\FastContains8.o}
  {$L asm\objs_X64\FastContains16.o}
  {$L asm\objs_X64\FastContains32.o}
  {$L asm\objs_X64\FastContains64.o}

  {$L asm\objs_X64\FastContainsFloat.o}
  {$L asm\objs_X64\FastContainsDouble.o}

  {$L asm\objs_X64\FastFind8.o}
  {$L asm\objs_X64\FastFind16.o}
  {$L asm\objs_X64\FastFind32.o}
  {$L asm\objs_X64\FastFind64.o}

  {$L asm\objs_X64\FastFindFloat.o}
  {$L asm\objs_X64\FastFindDouble.o}

  {$L asm\objs_X64\FastMinFloat.o}
  {$L asm\objs_X64\FastMinIdxFloat.o}
  {$L asm\objs_X64\FastMinDouble.o}
  {$L asm\objs_X64\FastMinIdxDouble.o}
  {$L asm\objs_X64\FastMinI8.o}
  {$L asm\objs_X64\FastMinIdxI8.o}
  {$L asm\objs_X64\FastMinI16.o}
  {$L asm\objs_X64\FastMinIdxI16.o}
  {$L asm\objs_X64\FastMinI32.o}
  {$L asm\objs_X64\FastMinIdxI32.o}
  {$L asm\objs_X64\FastMinI64.o}
  {$L asm\objs_X64\FastMinIdxI64.o}
  {$L asm\objs_X64\FastMinU8.o}
  {$L asm\objs_X64\FastMinIdxU8.o}
  {$L asm\objs_X64\FastMinU16.o}
  {$L asm\objs_X64\FastMinIdxU16.o}
  {$L asm\objs_X64\FastMinU32.o}
  {$L asm\objs_X64\FastMinIdxU32.o}
  {$L asm\objs_X64\FastMinU64.o}
  {$L asm\objs_X64\FastMinIdxU64.o}

  {$L asm\objs_X64\FastMaxFloat.o}
  {$L asm\objs_X64\FastMaxIdxFloat.o}
  {$L asm\objs_X64\FastMaxDouble.o}
  {$L asm\objs_X64\FastMaxIdxDouble.o}
  {$L asm\objs_X64\FastMaxI8.o}
  {$L asm\objs_X64\FastMaxIdxI8.o}
  {$L asm\objs_X64\FastMaxI16.o}
  {$L asm\objs_X64\FastMaxIdxI16.o}
  {$L asm\objs_X64\FastMaxI32.o}
  {$L asm\objs_X64\FastMaxIdxI32.o}
  {$L asm\objs_X64\FastMaxI64.o}
  {$L asm\objs_X64\FastMaxIdxI64.o}
  {$L asm\objs_X64\FastMaxU8.o}
  {$L asm\objs_X64\FastMaxIdxU8.o}
  {$L asm\objs_X64\FastMaxU16.o}
  {$L asm\objs_X64\FastMaxIdxU16.o}
  {$L asm\objs_X64\FastMaxU32.o}
  {$L asm\objs_X64\FastMaxIdxU32.o}
  {$L asm\objs_X64\FastMaxU64.o}
  {$L asm\objs_X64\FastMaxIdxU64.o}
 {$endif}


////////////////////////////////////////////////////////////////////////////////
function FastContains(const p: pint8_t; n: uint64_t; q: int8_t ):bool; inline; overload;
begin
 Exit( FastContains8(puint8_t(p), n, uint8_t(q)) );
end;

function FastContains(const p: puint8_t; n: uint64_t; q: uint8_t ):bool; inline; overload;
begin
 Exit( FastContains8(puint8_t(p), n, q) );
end;

Function FastContains(const p: pint16_t; n: uint64_t; q: int16_t ):bool; inline; overload;
begin
 Exit( FastContains16(puint16_t(p), n, uint16_t(q)) );
end;

Function FastContains(const p:puint16_t; n: uint64_t; q: uint16_t):bool; inline; overload;
begin
 Exit( FastContains16(puint16_t(p), n, q) );
end;

Function FastContains(const p:pint32_t; n:uint64_t; q:int32_t):bool; inline; overload;
begin
 Exit( FastContains32(puint32_t(p), n, uint32_t(q)) );
end;

Function FastContains(const p:puint32_t; n: uint64_t; q: uint32_t):bool; inline; overload;
begin
 Exit( FastContains32(puint32_t(p), n, q) );
end;

Function FastContains(const p:Pint64_t; n: uint64_t; q: int64_t):bool; inline; overload;
begin
 Exit( FastContains64(puint64_t(p), n, uint64_t(q)) );
end;

Function FastContains(const p:puint64_t; n: uint64_t; q: uint64_t):bool; inline; overload;
begin
 Exit( FastContains64(puint64_t(p), n, q) );
end;

Function FastContains(const p:Pfloat; n: uint64_t; q: float):bool; inline; overload;
begin
 Exit( FastContainsFloat(p, n, q) );
end;

Function FastContains(const p:pdouble; n: uint64_t; q: double):bool; inline; overload;
begin
 Exit( FastContainsDouble(p, n, q) );
end;

////////////////////////////////////////////////////////////////////////////////
Function FastFind(const p:pint8_t; n: uint64_t; q: int8_t): uint64_t; inline; overload;
begin
 Exit( FastFind8(p, n, uint8_t(q)) );
end;

Function FastFind(const p:puint8_t; n: uint64_t; q: uint8_t): uint64_t; inline; overload;
begin
 Exit( FastFind8(p, n, q) );
end;

Function FastFind(const p: pint16_t; n: uint64_t; q: int16_t): uint64_t; inline; overload;
begin
 Exit( FastFind16(p, n, uint16_t(q)) );
end;

Function FastFind(const p: puint16_t; n: uint64_t; q: uint16_t ): uint64_t; inline; overload;
begin
 Exit( FastFind16(p, n, q) );
end;

Function FastFind(const p:pint32_t; n: uint64_t; q: int32_t): uint64_t; inline; overload;
begin
 Exit( FastFind32(p, n, uint32_t(q)) );
end;

Function FastFind(const p: puint32_t; n: uint64_t; q: uint32_t): uint64_t; inline; overload;
begin
 Exit( FastFind32(p, n, q) );
end;

Function FastFind(const p: pint64_t; n: uint64_t; q: int64_t): uint64_t; inline; overload;
begin
 Exit( FastFind64(p, n, uint64_t(q)) );
end;

Function FastFind(const p:puint64_t; n: uint64_t; q: uint64_t): uint64_t; inline; overload;
begin
 Exit( FastFind64(p, n, q) );
end;

Function FastFind(const p:pfloat; n: uint64_t; q: float): uint64_t; inline; overload;
begin
 Exit( FastFindFloat(p, n, q) );
end;

Function FastFind(const p:pdouble; n: uint64_t; q: double): uint64_t; inline; overload;
begin
 Exit( FastFindDouble(p, n, q) );
end;

////////////////////////////////////////////////////////////////////////////////

Function FastMin( const p: pfloat; n: uint32_t; dummy:float=0 ):float;  inline; overload;
begin
 Exit( FastMinFloat(p, n) );
end;

Function FastMinIdx(const p: pfloat; n: uint32_t; dummy:float=0 ): uint32_t; inline; overload;
begin
 Exit( FastMinIdxFloat(p, n) );
end;

Function FastMin(const p: pdouble; n: uint32_t; dummy:double=0  ): double; inline; overload;
begin
 Exit( FastMinDouble(p, n) );
end;

Function FastMinIdx(const p: pdouble; n: uint32_t; dummy:double=0 ): uint32_t; inline; overload;
begin
 Exit( FastMinIdxDouble(p, n) );
end;

Function FastMin(const p: pint8_t; n: uint32_t; dummy:int8_t=0 ): int8_t; inline; overload;
begin
 Exit( FastMinI8(p, n) );
end;

Function FastMinIdx(const p: pint8_t; n: uint32_t; dummy:int8_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMinIdxI8(p, n) );
end;

Function FastMin(const p:pint16_t; n: uint32_t; dummy:int16_t=0 ): int16_t; inline; overload;
begin
 Exit( FastMinI16(p, n) );
end;

Function FastMinIdx(const p: pint16_t; n: uint32_t; dummy:int16_t=0):uint32_t; inline; overload;
begin
 Exit( FastMinIdxI16(p, n) );
end;

Function FastMin(const p: pint32_t; n: uint32_t; dummy:int32_t=0 ): int32_t; inline; overload;
begin
 Exit( FastMinI32(p, n) );
end;

Function FastMinIdx(const p: pint32_t; n: uint32_t; dummy:int32_t=0): uint32_t; inline; overload;
begin
 Exit( FastMinIdxI32(p, n) );
end;

Function FastMin(const p: pint64_t; n: uint32_t; dummy:int64_t=0 ): int64_t; inline; overload;
begin
 Exit( FastMinI64(p, n) );
end;

Function FastMinIdx(const p: pint64_t; n: uint32_t; dummy:int64_t=0): uint32_t; inline; overload;
begin
 Exit( FastMinIdxI64(p, n) );
end;

Function FastMin(const p: puint8_t; n: uint32_t; dummy:uint8_t=0 ): uint8_t; inline; overload;
begin
 Exit( FastMinU8(p, n) );
end;

Function FastMinIdx(const p: puint8_t; n: uint32_t; dummy:uint8_t=0): uint32_t; inline; overload;
begin
 Exit( FastMinIdxU8(p, n) );
end;

Function FastMin(const p: puint16_t; n: uint32_t; dummy:uint16_t=0 ): uint16_t; inline; overload;
begin
 Exit( FastMinU16(p, n) );
end;

Function FastMinIdx(const p: puint16_t; n: uint32_t; dummy:uint16_t=0): uint32_t; inline; overload;
begin
 Exit( FastMinIdxU16(p, n) );
end;

Function FastMin(const p: puint32_t; n: uint32_t; dummy:uint32_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMinU32(p, n) );
end;

Function FastMinIdx(const p: puint32_t; n: uint32_t; dummy:uint32_t=0): uint32_t; inline; overload;
begin
 Exit( FastMinIdxU32(p, n) );
end;

Function FastMin(const p: puint64_t; n: uint32_t; dummy:uint64_t=0 ): uint64_t; inline; overload;
begin
 Exit( FastMinU64(p, n) );
end;

Function FastMinIdx(const p: puint64_t; n: uint32_t; dummy:uint64_t=0): uint32_t; inline; overload;
begin
 Exit( FastMinIdxU64(p, n) );
end;


////////////////////////////////////////////////////////////////////////////////


Function FastMax(const p: pfloat; n: uint32_t; dummy:float=0 ): float; inline; overload;
begin
 Exit( FastMaxFloat(p, n) );
end;

Function FastMaxIdx(const p: pfloat; n: uint32_t; dummy:float=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxIdxFloat(p, n) );
end;

Function FastMax(const p: pdouble; n: uint32_t; dummy:double=0 ): double; inline; overload;
begin
 Exit( FastMaxDouble(p, n) );
end;

Function FastMaxIdx(const p: pdouble; n: uint32_t; dummy:double=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxIdxDouble(p, n) );
end;

Function FastMax(const p: pint8_t; n: uint32_t; dummy:int8_t=0 ): int8_t; inline; overload;
begin
 Exit( FastMaxI8(p, n) );
end;

Function FastMaxIdx(const p: pint8_t; n: uint32_t; dummy:int8_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxIdxI8(p, n) );
end;

Function FastMax(const p:pint16_t; n: uint32_t; dummy:int16_t=0 ): int16_t; inline; overload;
begin
 Exit( FastMaxI16(p, n));
end;

Function FastMaxIdx(const p:pint16_t; n: uint32_t; dummy:int16_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxIdxI16(p, n) );
end;

Function FastMax(const p:pint32_t; n: uint32_t; dummy:int32_t=0 ): int32_t; inline; overload;
begin
 Exit( FastMaxI32(p, n) );
end;

Function FastMaxIdx(const p:pint32_t; n: uint32_t; dummy:int32_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxIdxI32(p, n) );
end;

Function FastMax(const p:pint64_t; n: uint32_t; dummy:int64_t=0 ): int64_t; inline; overload;
begin
 Exit( FastMaxI64(p, n) );
end;

Function FastMaxIdx(const p:pint64_t; n: uint32_t; dummy:int64_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxIdxI64(p, n) );
end;

Function FastMax(const p:puint8_t; n: uint32_t; dummy:uint8_t=0 ): uint8_t; inline; overload;
begin
 Exit( FastMaxU8(p, n) );
end;

Function FastMaxIdx(const p:puint8_t; n: uint32_t; dummy:uint8_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxIdxU8(p, n) );
end;

Function FastMax(const p:puint16_t; n: uint32_t; dummy:uint16_t=0 ): uint16_t; inline; overload;
begin
 Exit( FastMaxU16(p, n) );
end;

Function FastMaxIdx(const p:puint16_t; n: uint32_t; dummy:uint16_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxIdxU16(p, n) );
end;

Function FastMax(const p:puint32_t; n: uint32_t; dummy:uint32_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxU32(p, n));
end;

Function FastMaxIdx(const p:puint32_t; n: uint32_t; dummy:uint32_t=0 ): uint32_t; inline; overload;
begin
 Exit( FastMaxIdxU32(p, n) );
end;

Function FastMax(const p:puint64_t; n: uint32_t; dummy:uint64_t=0 ): uint64_t; inline; overload;
begin
 Exit( FastMaxU64(p, n) );
end;

Function FastMaxIdx(const p:puint64_t; n: uint32_t; dummy:uint64_t=0 ): uint32_t ; inline; overload;
begin
 Exit( FastMaxIdxU64(p, n) );
end;


////////////////////////////////////////////////////////////////////////////////

class Procedure TArrayContainsValue.ContainsValue<T>(const anArrayOf: Array of T; const TargetValue; var Result: Boolean);
begin
 if (TypeInfo(T) = TypeInfo(int8_t)) then begin
  Result := FastContains( pint8_t(@anArrayOf), uint64_t(Length(anArrayOf)), int8_t(TargetValue) );
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int16_t)) then begin
  Result := FastContains( pint16_t(@anArrayOf), uint64_t(Length(anArrayOf)), int16_t(TargetValue) );
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int32_t)) then begin
  Result := FastContains( pint32_t(@anArrayOf), uint64_t(Length(anArrayOf)), int32_t(TargetValue) );
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int64_t)) then begin
  Result := FastContains( pint64_t(@anArrayOf[0]), uint64_t(Length(anArrayOf)), int64_t(TargetValue) );
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(float)) then begin
  Result := FastContains( pfloat(@anArrayOf), uint64_t(Length(anArrayOf)), float(TargetValue) );
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(double)) then begin
  Result := FastContains( pdouble(@anArrayOf), uint64_t(Length(anArrayOf)), double(TargetValue) );
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint8_t)) then begin
  Result := FastContains( puint8_t(@anArrayOf), uint64_t(Length(anArrayOf)), uint8_t(TargetValue) );
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint16_t)) then begin
  Result := FastContains( puint16_t(@anArrayOf), uint64_t(Length(anArrayOf)), uint16_t(TargetValue) );
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint32_t)) then begin
  Result := FastContains( puint32_t(@anArrayOf), uint64_t(Length(anArrayOf)), uint32_t(TargetValue) );
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint64_t)) then begin
  Result := FastContains( puint64_t(@anArrayOf), uint64_t(Length(anArrayOf)), uint64_t(TargetValue) );
  Exit;
 end;

end;

class Procedure TArrayMinFinder.MinValue<T>(const anArrayOf: Array of T; var Result);
begin
 if (TypeInfo(T) = TypeInfo(int8_t)) then begin
  int8_t(Result) := FastMin( pint8_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int16_t)) then begin
  int16_t(Result) := FastMin( pint16_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int32_t)) then begin
  int32_t(Result) := FastMin( pint32_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int64_t)) then begin
  int64_t(Result) := FastMin( pint64_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(float)) then begin
  float(Result) := FastMin( pfloat(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(double)) then begin
  double(Result) := FastMin( pdouble(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint8_t)) then begin
  uint8_t(Result) := FastMin( puint8_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint16_t)) then begin
  uint16_t(Result) := FastMin(puint16_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint32_t)) then begin
  uint32_t(Result) := FastMin( puint32_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint64_t)) then begin
  uint64_t(Result) := FastMin( puint64_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

end;

class Procedure TArrayMaxFinder.MaxValue<T>(const anArrayOf: Array of T; var Result);
begin
 if (TypeInfo(T) = TypeInfo(int8_t)) then begin
  int8_t(Result) := FastMax( pint8_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int16_t)) then begin
  int16_t(Result) := FastMax( pint16_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int32_t)) then begin
  int32_t(Result) := FastMax( pint32_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int64_t)) then begin
  int64_t(Result) := FastMax( pint64_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(float)) then begin
  float(Result) := FastMax( pfloat(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(double)) then begin
  double(Result) := FastMax( pdouble(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint8_t)) then begin
  uint8_t(Result) := FastMax( puint8_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint16_t)) then begin
  uint16_t(Result) := FastMax(puint16_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint32_t)) then begin
  uint32_t(Result) := FastMax( puint32_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint64_t)) then begin
  uint64_t(Result) := FastMax( puint64_t(@anArrayOf), uint32_t(Length(anArrayOf)));
  Exit;
 end;

end;

class procedure TClassicArrayMinFinder.ValueIndexOfMinimum<T>(const AValues: array of T; var IndexOfMin: Integer; var MinVal);
begin
 IndexOfMin      := -1;
 Integer(MinVal) := 0;
 if Length(AValues) = 0 then Exit;
 var LValIdx: Integer;
 var LMinIdx: Integer := 0;

 if (TypeInfo(T) = TypeInfo(int8_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( int8_t(pint8_t(@AValues[LValIdx])^) < int8_t(pint8_t(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  Int8_t(MinVal) := int8_t(pint8_t(@AValues[LMinIdx])^);
  IndexOfMin      := LMinIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int16_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( int16_t(pint16_t(@AValues[LValIdx])^) < int16_t(pint16_t(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  Int16_t(MinVal) := int16_t(pint16_t(@AValues[LMinIdx])^);
  IndexOfMin      := LMinIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int32_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( int32_t(pint32_t(@AValues[LValIdx])^) < int32_t(pint32_t(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  Int32_t(MinVal) := int32_t(pint32_t(@AValues[LMinIdx])^);
  IndexOfMin      := LMinIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int64_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( int64_t(pint64_t(@AValues[LValIdx])^) < int64_t(pint64_t(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  Int64_t(MinVal) := int64_t(pint64_t(@AValues[LMinIdx])^);
  IndexOfMin      := LMinIdx;
  Exit;
 end;


 if (TypeInfo(T) = TypeInfo(uint8_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( uint8_t(puint8_t(@AValues[LValIdx])^) < uint8_t(puint8_t(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  uInt8_t(MinVal) := uint8_t(puint8_t(@AValues[LMinIdx])^);
  IndexOfMin      := LMinIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int16_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( uint16_t(puint16_t(@AValues[LValIdx])^) < uint16_t(puint16_t(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  uInt16_t(MinVal) := uint16_t(puint16_t(@AValues[LMinIdx])^);
  IndexOfMin       := LMinIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint32_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( uint32_t(puint32_t(@AValues[LValIdx])^) < uint32_t(puint32_t(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  uInt32_t(MinVal) := uint32_t(puint32_t(@AValues[LMinIdx])^);
  IndexOfMin      := LMinIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint64_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( uint64_t(puint64_t(@AValues[LValIdx])^) < uint64_t(puint64_t(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  uInt64_t(MinVal) := uint64_t(puint64_t(@AValues[LMinIdx])^);
  IndexOfMin       := LMinIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(float)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( float(pfloat(@AValues[LValIdx])^) < float(pfloat(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  float(MinVal) := float(pfloat(@AValues[LMinIdx])^);
  IndexOfMin    := LMinIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(double)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( double(pdouble(@AValues[LValIdx])^) < double(pdouble(@AValues[LMinIdx])^) ) then LMinIdx := LValIdx;
  end;
  double(MinVal) := double(pdouble(@AValues[LMinIdx])^);
  IndexOfMin     := LMinIdx;
  Exit;
 end;

end;

class procedure TClassicArrayMaxFinder.ValueIndexOfMaximum<T>(const AValues: array of T; var IndexOfMax: Integer; var MaxVal);
begin
 IndexOfMax      := -1;
 Integer(MaxVal) := 0;
 if Length(AValues) = 0 then Exit;
 var LValIdx: Integer;
 var LMaxIdx: Integer := 0;

if (TypeInfo(T) = TypeInfo(int8_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( int8_t(pint8_t(@AValues[LValIdx])^) > int8_t(pint8_t(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  Int8_t(MaxVal) := int8_t(pint8_t(@AValues[LMaxIdx])^);
  IndexOfMax      := LMaxIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int16_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( int16_t(pint16_t(@AValues[LValIdx])^) > int16_t(pint16_t(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  Int16_t(MaxVal) := int16_t(pint16_t(@AValues[LMaxIdx])^);
  IndexOfMax      := LMaxIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int32_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( int32_t(pint32_t(@AValues[LValIdx])^) > int32_t(pint32_t(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  Int32_t(MaxVal) := int32_t(pint32_t(@AValues[LMaxIdx])^);
  IndexOfMax      := LMaxIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int64_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( int64_t(pint64_t(@AValues[LValIdx])^) > int64_t(pint64_t(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  Int64_t(MaxVal) := int64_t(pint64_t(@AValues[LMaxIdx])^);
  IndexOfMax      := LMaxIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint8_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( uint8_t(puint8_t(@AValues[LValIdx])^) > uint8_t(puint8_t(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  uInt8_t(MaxVal) := uint8_t(puint8_t(@AValues[LMaxIdx])^);
  IndexOfMax      := LMaxIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(int16_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( uint16_t(puint16_t(@AValues[LValIdx])^) > uint16_t(puint16_t(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  uInt16_t(MaxVal) := uint16_t(puint16_t(@AValues[LMaxIdx])^);
  IndexOfMax       := LMaxIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint32_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( uint32_t(puint32_t(@AValues[LValIdx])^) > uint32_t(puint32_t(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  uInt32_t(MaxVal) := uint32_t(puint32_t(@AValues[LMaxIdx])^);
  IndexOfMax      := LMaxIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(uint64_t)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( uint64_t(puint64_t(@AValues[LValIdx])^) > uint64_t(puint64_t(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  uInt64_t(MaxVal) := uint64_t(puint64_t(@AValues[LMaxIdx])^);
  IndexOfMax       := LMaxIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(float)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( float(pfloat(@AValues[LValIdx])^) > float(pfloat(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  float(MaxVal) := float(pfloat(@AValues[LMaxIdx])^);
  IndexOfMax    := LMaxIdx;
  Exit;
 end;

 if (TypeInfo(T) = TypeInfo(double)) then begin
  for LValIdx := 1 to High(AValues) do begin
   if ( double(pdouble(@AValues[LValIdx])^) > double(pdouble(@AValues[LMaxIdx])^) ) then LMaxIdx := LValIdx;
  end;
  double(MaxVal) := double(pdouble(@AValues[LMaxIdx])^);
  IndexOfMax     := LMaxIdx;
  Exit;
 end;

end;


class function TGenericMinMax.Max<T>(const values: array of T; const Comparer: IComparer<T>): T;
var
 item: T;
begin
 if length(values) >= 1 then begin
  Result := values[Low(values)];
  for item in values do
   if Comparer.Compare(item,Result) > 0 then
    Result := item
 end;
end;

class function TGenericMinMax.Min<T>(const values: array of T; const Comparer: IComparer<T>): T;
var
 item: T;
begin
 if length(values) >= 1 then begin
  Result := values[Low(values)];
  for item in values do
   if Comparer.Compare(item, Result) < 0 then
    Result := item
 end;
end;



function ArrayIndexOfMinimum(const AValues: array of Integer; var MinVal): Integer;
begin
 if Length(AValues) = 0 then Exit(-1);
 var LValIdx: Integer;
 var LMinIdx: Integer := 0;
 for LValIdx := 1 to High(AValues) do
  if (AValues[LValIdx] < AValues[LMinIdx]) then LMinIdx := LValIdx;
 Integer(MinVal) := AValues[LMinIdx];
 Result          := LMinIdx;
end;

function ArrayIndexOfMaximum(const AValues: array of Integer; var MaxVal): Integer;
begin
 var LValIdx: Integer;
 var LMaxIdx: Integer := 0;

 if Length(AValues) = 0 then Exit(-1);
 for LValIdx := 1 to High(AValues) do
  if (AValues[LValIdx] > AValues[LMaxIdx]) then LMaxIdx := LValIdx;
 Integer(MaxVal) := AValues[LMaxIdx];
 Result          := LMaxIdx;
end;



end.

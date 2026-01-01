{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V+}
unit Crc;
{ This unit provides three speed-optimized functions to compute (or continue
  computation of) a Cyclic Redundency Check (CRC).  These routines are
  contributed to the public domain (with the limitations noted by the
  original authors in the TASM sources).  Please see TESTCRC.PAS for
  example usage.

  Each function takes three parameters:

  InitCRC - The initial CRC value.  This may be the recommended initialization
  value if this is the first or only block to be checked, or this may be
  a previously computed CRC value if this is a continuation.

  InBuf - An untyped parameter specifying the beginning of the memory area
  to be checked.

  InLen - A word indicating the length of the memory area to be checked.  If
  InLen is zero, the function returns the value of InitCRC.

  The function result is the updated CRC.  The input buffer is scanned under
  the limitations of the 8086 segmented architecture, so the result will be
  in error if InLen > 64k - Offset(InBuf).

  These conversions were done on 10-29-89 by:

  Edwin T. Floyd [76067,747]
  #9 Adams Park Court
  Columbus, GA 31909
  (404) 576-3305 (work)
  (404) 322-0076 (home)
}
interface

function UpdateCRC16(InitCRC : word; var InBuf; InLen : word) : word;
{ I believe this is the CRC used by the XModem protocol.  The transmitting
  end should initialize with zero, UpdateCRC16 for the block, Continue the
  UpdateCRC16 for two nulls, and append the result (hi order byte first) to
  the transmitted block.  The receiver should initialize with zero and
  UpdateCRC16 for the received block including the two byte CRC.  The
  result will be zero (why?) if there were no transmission errors.  (I have
  not tested this function with an actual XModem implementation, though I
  did verify the behavior just described.  See TESTCRC.PAS.) }

function UpdateCRCArc(InitCRC : word; var InBuf; InLen : word) : word;
{ This function computes the CRC used by SEA's ARC utility.  Initialize
  with zero. }

function UpdateCRC32(InitCRC : longint; var InBuf; InLen : word) : longint;
{ This function computes the CRC used by PKZIP and Forsberg's ZModem.
  Initialize with high-values ($FFFFFFFF), and finish by inverting all bits
  (Not). }

implementation
  function UpdateCRC16(InitCRC : word; var InBuf; InLen : word) : word;
  external;
  {$L CRC16.OBJ }
  function UpdateCRCArc(InitCRC : word; var InBuf; InLen : word) : word;
  external;
  {$L CRCARC.OBJ }
  function UpdateCRC32(InitCRC : longint; var InBuf; InLen : word) : longint;
  external;
  {$L CRC32.OBJ }
end.

(****************************************************************)
(*                     DATABASE TOOLBOX 4.0                     *)
(*     Copyright (c) 1984, 87 by Borland International, Inc.    *)
(*                                                              *)
(*                        TASizes                               *)
(*                                                              *)
(*  Purpose: This program is invoked by TABuild to output the   *)
(*           sizes of the users record and key definitons.      *)
(*           You can also use this program to generate these    *)
(*           values if you have more than one data record or    *)
(*           key and you want to compare their sizes.           *)
(*                                                              *)
(****************************************************************)
program TASizes;
{$I  taccess.typ}
{    ^^^^^^^ Include file with user declarations for MaxDataType }
{ and MaxKeyType.  This file is created by TABuild. }
begin
  Writeln(output, 'MaxDataRecSize = ', SizeOf(MaxDataType));
  Writeln(output, 'MaxKeyLen = ', SizeOf(MaxKeyType) - 1);
end.


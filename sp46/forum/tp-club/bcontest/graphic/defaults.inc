  {**************************}
  {* ArtGraph ToolBox 3.0   *}
  {* SOFT-ARTEL      1991   *}
  {* Leningrad, USSR        *}
  {**************************}

{*******************************************}
{*      Common compilation directives      *}
{*******************************************}

{$A+,B-,D+,F-,I-,L+,O-,R-,S-,V-}
{$N-,E-}  {This directive enables and disables support of 8x87 data types}
{$M 16384,0,655360}

{************************************************}
{*      Conditional compilation directives      *}
{************************************************}

{$DEFINE MENU}   { when variable is undefined menu is not used }
{$DEFINE DISK}   { when variable is undefined save/load is unavailable }
{$DEFINE PRINT}  { when variable is undefined printing is unavailable }

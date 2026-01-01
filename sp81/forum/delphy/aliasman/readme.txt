
BDE Alias Manager
Version 1.0

Program and Documentation
Copyright (c) 1995 Mark E. Edington
Compuserve: 75140,2240

Introduction

  This component provides BDE alias creation and editing capabilities.
  The primary use is for creating aliases during program installation
  or initialization.

  The AliasMan unit can be used directly or installed as a component.
  If the component is installed, you can manage aliases at design
  time by double clicking on the TAliasManager component.  If all you
  need to do is create aliases in your program, you can just add
  AliasMan to your Uses clause, and call the AddAlias or AddStdAlias
  procedures.

  Please see the ALIASMAN.INT file for a description of the various
  methods and properties.

Component Installation

  By default, the AliasManager component will be placed on the
  Data Access page of the component palette.  You can change
  where it gets installed by editing the AMANREG.PAS file or
  by moving it after installation through the palette configuration.

  1) Place the distribution files in the Delphi LIB directory, or in
     another directory.
  2) Run Delphi and Chose Options | Install components.
  3) Make sure the Search Path contains the directory with the
     distribution files.
  4) Click the Add button and enter "AMANREG".
  5) Click OK.

File List

  README.TXT   - This file
  ALIASMAN.INT - Alias Manager component class declaration & documentation
  ALIASMAN.DCU - Alias Manager unit
  AMANEDIT.*   - Alias Property Editor Form
  NEWDLG.*     - New Alias Dialog (Form)
  AMANREG.PAS  - TAliasManager component registration unit
  PROPSTR.PAS  - TPropStringList (TStringList extension)

Additional Notes

  Because this program modifies the BDE configuration file, it is
  strongly recommended that you backup your IDAPI.CFG file before
  using this component.

  Most of the methods use a parameter of type TPropStringList.
  This is an extension to the Delphi TStringList class.  When
  coding be careful to use the "Value" property and not the "Values"
  property of TStringList.

Know Problems

  The alias property editor form does not provide the same level of
  functionality as the BDE Configuration utility.  For instance, there
  are no drop down lists for setting the property values.  The
  property editor may be enhanced in a future release.  However, this
  component is not intended to replace the BDE Configuration utility,
  but rather to provide a way for Delphi developers to programatically
  alter the BDE configuration.

Support

  If you find a problem with the AliasManager component, please send a
  report via Compuserve Mail to 75140,2240.  I can't promise that I will
  be able to answer all questions, or solve all problems, but I will make
  my best effort.

Warranty

  No warranties expressed or implied.  Use at your own risk.

unit mcfg_2;

{
  MCFG/2 -- marieconfig version 2

  This unit is a manual translation of the main header file of MCFG/2 with some
  wrapper functions to make working with MCFG/2 using fpc a bit more pleasant.
  All functions which are directly linked to the MCFG/2 functions are prefixed
  with "__extern_"

  See: https://github.com/FelixEcker/mcfg_2

  Original File   : include/mcfg.h
  MCFG/2 Version  : 0.3.3
  Author          : Marie Eckert

  Copyright (c) 2024, Marie Eckert
  This Unit is licensed under the BSD 3-Clause license.
}

interface

{$linklib mcfg_2}

uses baseunix, ctypes, Types;

const
  sharedobject = 'mcfg_2';
  mcfg_2_version = '0.3.2 (develop)';

type
  TMCFGErr = (meOK, meTODO, meINVALID_PARSER_STATE, meSYNTAX_ERROR, meINVALID_KEYWORD,
              meEND_IN_NOWHERE, meSTRUCTURE_ERROR, meDUPLICATE_SECTOR,
              meDUPLICATE_SECTION, meDUPLICATE_FIELD, meDUPLICATE_DYNFIELD,
              meINVALID_TYPE, meNULLPTR, meINTEGER_OUT_OF_BOUNDS, meMALLOC_FAIL,
              meOS_ERROR_MASK = $f000);

  TMCFGFieldType = (mftINVALID = -1, mftSTRING, mftLIST, mftBOOL, mftI8, mftU8, mftI16,
                    mftU16, mftI32, mftU32);
  
  TMCFGToken = (mtINVALID = -1, mtSECTOR, mtSECTION, mtEND, mtCOMMENT, mtSTR, mtLIST, mtBOOL,
                mtI8, mtU8, mtI16, mtU16, mtI32, mtU32, mtEMPTY);

  {$PACKRECORDS C}
  TMCFGField = record
    name: PChar;
    type_: TMCFGFieldType;
    data: Pointer;
    size: size_t;
  end;

  PMCFGField = ^TMCFGField;

  TMCFGList = record
    type_: TMCFGFieldType;
    field_count: size_t;
    fields: PMCFGField;
  end;

  TMCFGSection = record
    name: PChar;
    field_count: size_t;
    fields: PMCFGField;
  end;

  PMCFGSection = ^TMCFGSection;

  TMCFGSector = record
    name: PChar;
    section_count: size_t;
    sections: PMCFGSection;
  end;

  PMCFGSector = ^TMCFGSector;

  TMCFGFile = record
    sector_count: size_t;
    sectors: PMCFGSector;
    dynfield_count: size_t;
    dynfields: PMCFGField;
  end;

  PMCFGFile = ^TMCFGFile;

  TMCFGParserCtxt = record
    target_file: PMCFGFile;
    target_sector: PMCFGSector;
    target_section: PMCFGSection;
    target_field: PMCFGField;
    linenum: UInt32;
    file_path: PChar;
  end;

  PMCFGParserCtxt = ^TMCFGParserCtxt;

  TMCFGDataParseResult = record
    error: TMCFGErr;
    parse_end: PChar;
    multiline: Boolean;
    data: Pointer;
    size: size_t;
  end;

  PMCFGDataParseResult = ^TMCFGDataParseResult;

  {*
   * @brief Get the according string name/description for the input
   * @param err The error enum value
   * @return Matching string name/description for input; "invalid error code" if
   * no matching string could be found. Inputs which match MCFG_OS_ERROR_MASK will
   * return the return value of strerror and require the return value to be freed
   * after usage.
    }
  function __extern_mcfg_err_string(err:mcfg_err_t):^cchar;cdecl;external External_library name 'mcfg_err_string';

  {*
   * @brief Get the size for the given type in bytes.
   * @param type The type to get the size of
   * @return -1 if the type is invalid or its size is dynamic. Otherwise a
   * positive number indicating the size of the datatype in bytes.
    }
  function __extern_mcfg_sizeof(_type:mcfg_field_type_t):ssize_t;cdecl;external External_library name 'mcfg_sizeof';

  {*
   * @brief Convert the input string to its matching mcfg_field_type enum.
   * @param strtype The string for which to find the matching mcfg_field_type enum
   * @return Matching mcfg_field_type enum. Returns TYPE_INVALID if no match could
   * be found.
    }
  function __extern_mcfg_str_to_type(strtype:PChar):mcfg_field_type_t;cdecl;external External_library name 'mcfg_str_to_type';

  {*
   * @brief Gets the count of tokens in the input string
   * @param in The string for which to count the tokens
   * @return The amount of tokens found in the string, space-seperated.
    }
  function __extern_mcfg_get_token_count(in:PChar):size_t;cdecl;external External_library name 'mcfg_get_token_count';

  {*
   * @brief Gets the token at index from string in.
   * @param in The string from which to get the token
   * @param index The 0-based index of the token to be grabbed.
   * @return The token at index. If the string is emtpy or the index invalid an
   * empty string is returned. Every return value is allocated on the heap so it
   * has to be freed.
    }
  function __extern_mcfg_get_token_raw(in:PChar; index:uint16_t):^cchar;cdecl;external External_library name 'mcfg_get_token_raw';

  {*
   * @brief Gets the mcfg_token enum value for token at index from string in.
   * @param in The string from which to get the token
   * @param index The 0-based index of the token to be grabbed.
   * @return The mcfg_token enum value for the token at index. Returns
   * TOKEN_INVALID if index is invalid, input string is empty/NULL or no valid
   * token could be found at index.
    }
  function __extern_mcfg_get_token(in:PChar; index:uint16_t):mcfg_token_t;cdecl;external External_library name 'mcfg_get_token';

  {*
   * @brief Parses a field-declaration.
   * @param type The type of the field
   * @param str The entire line of the field declaration.
   * @return see declaration of struct mcfg_data_parse_result
    }
  function __extern_mcfg_parse_field_data(_type:mcfg_field_type_t; str:PChar):mcfg_data_parse_result_t;cdecl;external External_library name 'mcfg_parse_field_data';

  {*
   * @brief Parse a line of mcfg
   * @param line The line to be parsed
   * @param ctxt The parser context in which the line is to be parsed
   * @return MCFG_OK if no errors occured, for other return values see the
   * declaration of mcfg_err_t.
    }
  function __extern_mcfg_parse_line(line:PChar; ctxt:Pmcfg_parser_ctxt_t):mcfg_err_t;cdecl;external External_library name 'mcfg_parse_line';

  {*
   * @brief Parse a file from disk
   * @param path The path to the file
   * @param file The mcfg_file struct into which the file should be parsed
   * @param ctxt_out Location for the parser context to be put. Can be NULL
   * @return MCFG_OK if no errors occured, for other return values see the
   * declaration of mcfg_err_t.
    }
  function __extern_mcfg_parse_file_ctxto(path:PChar; file:Pmcfg_file_t; ctxt_out:PPmcfg_parser_ctxt_t):mcfg_err_t;cdecl;external External_library name 'mcfg_parse_file_ctxto';

  {*
   * @brief Parse a file from disk
   * @param path The path to the file
   * @param file The mcfg_file struct into which the file should be parsed
   * @return MCFG_OK if no errors occured, for other return values see the
   * declaration of mcfg_err_t.
    }
  function __extern_mcfg_parse_file(path:PChar; file:Pmcfg_file_t):mcfg_err_t;cdecl;external External_library name 'mcfg_parse_file';

  {*
   * @brief Add a sector to a file
   * @param file The mcfg_file struct into which the sector should be added
   * @param name The name of the sector to be added
   * @return MCFG_OK if no errors occured, MCFG_DUPLICATE_SECTOR if a sector with
   * given name already exists in file.
    }
  function __extern_mcfg_add_sector(file:Pmcfg_file_t; name:PChar):mcfg_err_t;cdecl;external External_library name 'mcfg_add_sector';

  {*
   * @brief Add a section to a sector
   * @param sector The mcfg_sector struct into which the section should be added
   * @param name The name of the section to be added
   * @return MCFG_OK if no errors occured, MCFG_DUPLICATE_SECTION if a section
   * with given name already exists in sector.
    }
  function __extern_mcfg_add_section(sector:Pmcfg_sector_t; name:PChar):mcfg_err_t;cdecl;external External_library name 'mcfg_add_section';

  {*
   * @brief Add a dynfield to a file
   * @param file The mcfg_file struct into which the dynfield should be added
   * @param type The datatype of the dynfield which is to be added
   * @param name The name of the dynfield which is to be added
   * @param data Pointer to the data of the dynfield which is to be added
   * @param size The size of data in bytes
   * @return MCFG_OK if no errors occured, MCFG_DUPLICATE_DYNFIELD if a dynfield
   * with the given name already exists in the file.
    }
  function __extern_mcfg_add_dynfield(file:Pmcfg_file_t; _type:mcfg_field_type_t; name:PChar; data:pointer; size:size_t):mcfg_err_t;cdecl;external External_library name 'mcfg_add_dynfield';

  {*
   * @brief Add a field to a section
   * @param section The mcfg_section struct into which the field should be added
   * @param type The datatype of the field which is to be added
   * @param name The name of the field which is to be added
   * @param data Pointer to the data of the field which is to be added
   * @param size The size of data in bytes
   * @return MCFG_OK if no errors occured, MCFG_DUPLICATE_FIELD if a field with
   * given name already exists in section.
    }
  function __extern_mcfg_add_field(section:Pmcfg_section_t; _type:mcfg_field_type_t; name:PChar; data:pointer; size:size_t):mcfg_err_t;cdecl;external External_library name 'mcfg_add_field';

  {*
   * @brief Add a field to a list
   * @param list The mcfg_list to add the field to
   * @param size The size of the data of the new field
   * @param data Pointer to the data of the new field
   * @return MCFG_OK if no errors occured, MCFG_NULLPTR if list or data is NULL.
    }
  function __extern_mcfg_add_list_field(list:Pmcfg_list_t; size:size_t; data:pointer):mcfg_err_t;cdecl;external External_library name 'mcfg_add_list_field';

  {*
   * @brief Get the sector with name from file
   * @param file The file from which the sector is to be grabbed
   * @param name The name of the sector
   * @return Pointer to the sector, NULL if no sector with given name could be
   * found.
    }
  function __extern_mcfg_get_sector(file:Pmcfg_file_t; name:PChar):^mcfg_sector_t;cdecl;external External_library name 'mcfg_get_sector';

  {*
   * @brief Get the section with name from sector
   * @param sector The sector from which the section is to be grabbed
   * @param name The name of the section
   * @return Pointer to the section, NULL if no section with given name could be
   * found.
    }
  function __extern_mcfg_get_section(sector:Pmcfg_sector_t; name:PChar):^mcfg_section_t;cdecl;external External_library name 'mcfg_get_section';

  {*
   * @brief Get the dynamically generated fiekd with name from file
   * @param file The file from which the field is to be grabbed
   * @param name The name of the dynfield.
   * @return Pointer to the field, NULL if no field with given name could be
   * found.
    }
  function __extern_mcfg_get_dynfield(file:Pmcfg_file_t; name:PChar):^mcfg_field_t;cdecl;external External_library name 'mcfg_get_dynfield';

  {*
   * @brief Get the field with name from section
   * @param section The section from which the field is to be grabbed
   * @param name The name of the field
   * @return Pointer to the field, NULL if no field with given name could be
   * found.
    }
  function __extern_mcfg_get_field(section:Pmcfg_section_t; name:PChar):^mcfg_field_t;cdecl;external External_library name 'mcfg_get_field';

  {*
   * @brief Free the contents of given list
   * @param list The list of which the contents should be freed
    }
  procedure __extern_mcfg_free_list(list:Pmcfg_list_t);cdecl;external External_library name 'mcfg_free_list';

  {*
   * @brief Free the contents of given field
   * @param field The field of which the contents should be freed
    }
  procedure __extern_mcfg_free_field(field:Pmcfg_field_t);cdecl;external External_library name 'mcfg_free_field';

  {*
   * @brief Free the contents of given section
   * @param section The section of which the contents should be freed
    }
  procedure __extern_mcfg_free_section(section:Pmcfg_section_t);cdecl;external External_library name 'mcfg_free_section';

  {*
   * @brief Free the contents of given sector
   * @param sector The sector of which the contents should be freed
    }
  procedure __extern_mcfg_free_sector(sector:Pmcfg_sector_t);cdecl;external External_library name 'mcfg_free_sector';

  {*
   * @brief Free the given file
   * @param file The file which should be freed.
    }
  procedure __extern_mcfg_free_file(file:Pmcfg_file_t);cdecl;external External_library name 'mcfg_free_file';

implementation
end.

What makes zqcc different from id's qcc

- "local" is not required before local variables
- semicolon after function body is optional
- redundant semicolons at file scope are allowed
- empty statements are allowed
- empty curly braces are allowed
- variables of type 'void' are forbidden, except for end_sys_fields and end_sys_globals
- C-style function declarations and definitions are allowed
- hexadecimal numeric constants are understood
- const modifier is supported, e.g. "const float IT_SHOTGUN = 0x01;"
  constants may not be assigned to
- varargs builtin functions with some required parms are supported.
  e.g. "void bprint(float level, string s, ...)"
- simple preprocessor functionality:
    1.) Defines
        #define <name> [<value>]
      creates a new define - value is optional and has currently no effect
        #undef <name>
      delete an existing define
    2.) Reserved Defines
      the internally define _ZQCC is always present and can be used to detect
        the compiler, e.g.
          #ifndef _ZQCC
          #error "Code may only be compiled with zqcc!"
          #endif
    3.) Conditional expressions for defines (nested conditions are allowed):
        #ifdef <name>
          <statements if name is defined>
        #else
          <statements if name is not defined>
        #endif
      or
        #ifndef <name>
          <statements if name is not defined>
        #else
          <statements if name is defined>
        #endif
      The #else cases are optional;
    4.) Message-Output
        #error "<Error Message>"
      print out the given message and stop the compilation.
        #message "<Normal Message>"
        #pragma message "<Normal Message>"
      prints out the given message and continue compilation;
        "#pragma message" is a compatibility synonym for "#message"
    5.) Limits for preprocessor defines:
      - max. 128 defines are allowed
			- in progs.src only allowed after first valid line (after definition of the output filename)
      - defines may only be used in #ifdef etc., may not be used as constants (maybe in future)
      - only simple defines may be used; arithmetics, parentheses etc. are not allowed.
      - reserved defines (=internally defined) may not be changed or undefined.


%{
/*
 * This is the initial declarations block within the definitions section of
 * the Flex specification file.  Any code can be written here, and it will
 * be copied verbatim to the top of the generated scanner code file.
 *
 * Below, we define a single name, DIGIT, and we specify two Flex options
 * directives.
 */
#include <iostream>
%}

DIGIT [0-9]

%option noyywrap
%option yylineno

%%

%{
    /*
     * This is the rules section.  A code block like this one can be included
     * at the top of the rules section, and the code within will be copied
     * verbatim to the top of the generated scanning function (within the
     * function).
     */
%}

a       {
          /*
           * This rule recognizes the single character 'a'.  The code within
           * this set of brackets is the action for this rule.  It will be run
           * whenever the token 'a' is recognized in the input source code.
           */

          std::cout << "The text of the matched string is available in yytext: " << yytext << std::endl;
          std::cout << "The length of the matched string is available in yyleng: " << yyleng << std::endl;

          /*
           * Any single character can be put back into the input stream using
           * unput().  Note that this destroys the contents of yytext.
           */
          unput('x');

          /*
           * The next character in the input stream can be consumed using
           * input() (if you're compiling as C code) or yyinput() (if you're
           * compiling as C++ code).
           */
          int c = yyinput();

          /*
           * When a Flex-generated scanner runs, multiple rules might match a
           * given string in the input source code, and by convention, Flex
           * applies the one that matches the longest possible sequence of
           * characters.  IF more than one rule matches that longest possible
           * sequence of characters, the rule defined first is run.
           *
           * The REJECT macro can be called from an action to explicitly run
           * that "next-best" matching rule.  For instance, in this case, the
           * [abc] rule below will be the next-best matching rule whenever we
           * see an 'a' character (causing this current rule to run), so
           * this call to REJECT will result in the [abc] rule's action being
           * run in addition to this one.
           */
          REJECT;
        }

cat     {
          /*
           * This rule recognizes the concatenation of 'c', 'a', and 't',
           * i.e. the string "cat".
           */

          /*
           * yyterminate() forces the scanning function yylex() to return 0.
           */
          yyterminate();
        }

cat|dog {
          /*
           * This rule recognizes the union of "cat" and "dog", i.e. either
           * "cat" or "dog".
           */
        }

ca*t    {
          /*
           * This rule contains a closure operator.  It recognizes a 'c',
           * followed by zero or more 'a's, followed by a 't'.  The following
           * strings (plus others) all match this pattern:
           *
           * ct
           * cat
           * caaaaaat
           * caaaaaaaaaaaaaaaaaaaaaat
           */
        }

ca+t    {
          /*
           * This rule contains a positive closure operator.  It recognizes a
           * 'c', followed by one or more 'a's, followed by a 't'.  This
           * pattern matches the same strings as the one above, except for
           * "ct".
           */
        }

ca?t    {
          /*
           * This rule contains an optional operator.  It recognizes a 'c',
           * followed by zero or one 'a's, followed by a 't', i.e, either the
           * string "ct" or the string "cat".
           */
        }

\n      {
          /*
           * This rule contains an escape sequence.  It matches a single
           * newline character.
           */
        }

\r\n    {
          /*
           * This rule contains escape sequences to match a DOS-style newline.
           */
        }

\t      {
          /*
           * This rule contains an escape sequence to match a single tab
           * character.
           */
        }

\?      {
          /*
           * This rule uses an escape sequence to match a single '?' character.
           * The escape is needed because ? is a regular expression operator.
           */
        }

[abc]   {
          /*
           * This rule contains a character class.  It matches a single
           * character that is either 'a', 'b', or 'c'.
           */
        }

[ \t\n] {
          /*
           * This rule contains a character class to match whitespace, i.e. a
           * single character that is either ' ', '\t', or '\n'.
           */
        }

[0-9]   {
          /*
           * This rule contains a character range class.  It matches a single
           * character that is either '0', '1', '2', '3', '4', '5', '6', '7',
           * '8', or '9'.
           */
        }

[0-9a-zA-Z]   {
                /*
                 * This rule contains a character range class to match any
                 * single alphanumeric character.
                 */
              }

[^cat]    {
            /*
             * This rule contains a complement.  It matches any single
             * character that is NOT 'c', 'a', or 't'.
             */
          }

[^ \t\n]  {
            /*
             * This rule contains a complement that matches any single
             * non-whitespace character.
             */
          }

^cat    {
          /*
           * This rule contains a beginning-of-line operator.  It matches
           * the string "cat" only if it appears at the very beginning of a
           * new line.
           */
        }

^\n     {
          /*
           * This rule contains a beginning-of-line operator to match a
           * newline that appears at the beginning of a line.
           */
        }

cat$    {
          /*
           * This rule contains an end-of-line operator.  It matches the string
           * "cat" only if it appears at the very end of a line.
           */
        }

;$      {
          /*
           * This rule uses an end-of-line operator to match a semicolon at
           * the end of a line.
           */
        }

"c.t"   {
          /*
           * This operator uses double quotes to match the literal string
           * "c.t".  Note that in this case, the . matches the literal
           * character '.' instead of any character.
           */
        }

c(a|u)*t  {
            /*
             * This string uses parentheses to override the order of operations.
             */
           }

.       {
          /*
           * The . operator matches any single character other than a newline.
           */
         }

%%

/*
 * This is the user code section.  Any code can be written here, and it will
 * be copied to the bottom of the generated scanner code file.  Here, we
 * just include a simple main() function that calls the generated scanning
 * function, yylex().
 */
int main() {
  yylex();
}

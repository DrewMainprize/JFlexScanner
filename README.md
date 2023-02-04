Drew Mainprize
1045298
For CIS*4650, Fei Song
Warmup Assignment


******Important******
Code from Professor Fei Song was used for this assignment.
Specifically the Scanner.java and Token.java files resemble
those from class with minor variations to the Token.java file.

sgml.flex was based off of the code in tiny.flex that was provided,
however with little similarity as the languages are unique.


******To Build and Run******
- Update the path to jflex in the makefile to wherever it is located on your machine

- cd into dmainpri_a1

- $ make

- $ java Scanner < inputFile.txt

- Optional to direct output to another file instead of console:
  $ java Scanner < inputFile.txt > outputFile.txt

- To clean the directory:
  $ make clean




Problem:
For this assignment I built a simple scanner for the SGML language which
is a markup language similar to HTML where all the tags have an open 
and closing tag.

Assumptions:
The scanner can only properly handle tags that are in the form <EX></EX>
It will fail to handle tags in any other form and may give unexpected 
behaviour.

Tags with attributes to them are not printed to the console. The tag is
printed but the attribute is thrown away

Given more time, I would have liked to cover a few more edge cases in my
 assignment. The discussion boards hosted many examples of these edge 
cases but due to time constraints I was not able to fully implement 
every edge case that was discussed.



Test Plan:

I tested my program with various combinations of punctuation, 
whitespace, tag-names and other edge cases to assure that my program was 
running correctly.

Numbers:
- tested with +/- signs and without
- tested with real numbers and integers
- tested with edge cases such as .0 and 0.

Hyphen/Apostrophe:
- tested with hyphens at the beginning, end and middle of words
- tested with hyphens and apostrophe's to make sure that the output was 
directed to apostrophe instead of hyphen

Punctuation:
- tested with punctuation in the middle of words
- tested with punctuation that serves multiple purposes
 ex. < and > as well as ' and - outside of thier other context





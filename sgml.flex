/*
  File Name: sgml.flex
  JFlex specification for SGML language
*/
import java.util.ArrayList; 
%%
   
%class Lexer
%type Token
%line
%column

%{
  //Need to put this above so we can define getTagName();
  private static ArrayList<String> myStack = new ArrayList<String>();

  // static method such as getTagName can be defined here as well
  public static void getTagName(ArrayList<String> stack){

	for(int i = 0; i < stack.size(); i++){
		System.out.println(stack.get(i));
	}

  }
%};

%eofval{
  //System.out.println("*** Reaching end of file");

  if(!myStack.isEmpty()){
	System.out.println("Still tags open on the stack, printing them now:");

	getTagName(myStack);
  }

  return null;

%eofval};

/* A line terminator is a \r (carriage return), \n (line feed), or
   \r\n. */
LineTerminator = \r|\n|\r\n

/* White space is a line terminator, space, tab, or form feed. */
WhiteSpace     = {LineTerminator} | [ \t\f]

/* A literal integer is is a number beginning with a number between
   one and nine followed by zero or more numbers between zero and nine
   or just a zero.  */
digit = [0-9]
//Commented because did not use
//num = {digit}+ // Probably not going to use this so change to num

/* A identifier integer is a word beginning a letter between A and
   Z, a and z, or an underscore followed by zero or more letters
   between A and Z, a and z, zero and nine, or an underscore. */
letter = [a-zA-Z]
//Commented because did not use
//identifier = {letter}+


//My reg. expressions for parser

//WORD: String of characters and numbers
//Must contain a character otherwise it is a number

word = ({letter}|{digit})*{letter}({letter}|{digit})*


//NUMBER: Can have +/- sign, can have a decimal or no decimal
//First conditional: Capture +/-, either one or zero (hence the '?')

number = ("-"|"+")?({digit}+"."?{digit}+)|({digit}*"."{digit}+|{digit}+)


//APOSTROPHE: Can have ' sign \, but must be in middle of word
//As a limitation, I have not considered words with an apostrophe at the end
//as to not confuse the scanner with words at the end of a single quoted sentence

apostrophe = ({letter}|{digit})+"'"({letter}|{digit})+("'"({letter}|{digit})+)*


//HYPHEN: Must have the - sign in the middle of the word
//Also includes words that have apostrophe's and hyphens
//As per the assignment spec, the hyApos token will be considered a apostrophe token
hyphen = ({letter}|{digit})+"-"({letter}|{digit})+("-"({letter}|{digit})+)* 
hyApos = (({letter}|{digit})+"-"{apostrophe}|({letter}|{digit})+"-"({letter}|{digit})+"-"{apostrophe}) 


//PUNCTUATION: Self explanatory, contains all punctuation marks
//Also contains all < and > signs that are not a part of an open or closed tag
punctuation = [^ \r\n\ta-zA-Z0-9"<"">"] //Anything that does not fall under that categories above



%%

/*
   This section contains regular expressions and actions, i.e. Java
   code, that will be executed when the scanner matches the associated
   regular expression. */
   



{WhiteSpace}	{/*Skip over whitespace*/}
{word}			{ return new Token(Token.WORD, yytext(), yyline, yycolumn, 0); }
{number}		{ return new Token(Token.NUMBER, yytext(), yyline, yycolumn, 0); }
{apostrophe}	{ return new Token(Token.APOSTROPHIZED, yytext(), yyline, yycolumn, 0); }
{hyApos}		{ return new Token(Token.APOSTROPHIZED, yytext(), yyline, yycolumn, 0); }
{hyphen}		{ return new Token(Token.HYPHEN, yytext(), yyline, yycolumn, 0); }
{punctuation}	{ return new Token(Token.PUNCTUATION, yytext(), yyline, yycolumn, 0); }





//Code for finding open tags
"<"{WhiteSpace}*[0-9a-zA-Z"-""_"]+{WhiteSpace}*([0-9a-zA-Z"-""_"]+{WhiteSpace}*"="{WhiteSpace}*"\""{WhiteSpace}*[0-9a-zA-Z"-""_"]+{WhiteSpace}*"\"")?{WhiteSpace}*">" { 

	int start;
	int end;
	String openTag = yytext();
	int relevant = 0;

	//Find first non-whitespace character in the open tag
	//Saved in variable 'start' as the index the open tag starts with
	for(start = 0; start < openTag.length(); start++) {

		//Use standard Java functions to compute if the character is a letter or digit
		if(Character.isAlphabetic(openTag.charAt(start)) || Character.isDigit(openTag.charAt(start))){
			break;
		}
		//Also checking that there is no underscore or hyphen to start the tag
		if((openTag.charAt(start) == '_' && openTag.charAt(start) == '-')) {
			break;
		}
	}

	//Find end index of the open tag, will be a > symbol.
	for(end = start; end < openTag.length(); end++) {

		if(openTag.charAt(end) == '>' || openTag.charAt(end) == ' ') {
				break;
		}	
	}	

	//Slice the tag down to only the tag name and convert to uppercase
	openTag = openTag.substring(start, end).toUpperCase();
												
	//If the tag name is relevant it will be written to output
	if(openTag.equals("TEXT") || openTag.equals("DATE") || openTag.equals("DOC") || openTag.equals("DOCNO") || openTag.equals("HEADLINE") || openTag.equals("LENGTH")) {
		relevant = 1;
	}

	//If <P> check the previous tag for relevance
	if(openTag.equals("P")) {
		String previousTag = myStack.get(myStack.size() - 1);
		if(previousTag.equals("TEXT") || previousTag.equals("DATE") || previousTag.equals("DOC") || previousTag.equals("DOCNO") || previousTag.equals("HEADLINE") || previousTag.equals("LENGTH")) {
			relevant = 1;
		} else {
			relevant = 0;
		}
	}
	myStack.add(openTag); //Push tag to stack

	return new Token(Token.OPEN, openTag, yyline, yycolumn, relevant); 
}


//Code for finding closed tags
"</"{WhiteSpace}*[0-9a-zA-Z"-""_"][0-9a-zA-Z"-""_"]*{WhiteSpace}*">" {

	int start;
	int end;
	int relevant = 0;
	String closeTag = yytext();

	//Find first non-whitespace character in the open tag
	//Saved in variable 'start' as the index the open tag starts with
	for(start = 0; start < closeTag.length(); start++) {

		//Use standard Java functions to compute if the character is a letter or digit
		if(Character.isAlphabetic(closeTag.charAt(start)) || Character.isDigit(closeTag.charAt(start))){
			break;
		}
		//Also checking that there is no underscore or hyphen to start the tag
		if((closeTag.charAt(start) == '_' && closeTag.charAt(start) == '-')) {
			break;
		}
	}

	//Find end index of the open tag, will be a > symbol.
	for(end = start; end < closeTag.length(); end++) {
		if(closeTag.charAt(end) == ' ' || closeTag.charAt(end) == '>') {
			break;
		}	
	}

	//Slice the tag down to only the tag name and convert to uppercase
	closeTag = closeTag.substring(start, end).toUpperCase();
											
	//Match the close tag to the top tag on the stack, if they don't match print error message
	if(!myStack.get(myStack.size()-1).equals(closeTag)) {
		System.out.println("Open tag does not match closing tag named "+closeTag);

		//Return error tag
		return new Token(Token.ERROR, closeTag, yyline, yycolumn, -1);	

	} else {
		//If there is a match we can remove the top tag off the stack as it is now closed
		myStack.remove(myStack.size() - 1);

		//Check if the top tag is relevant and set relevance of the close tag to match
		if(!myStack.isEmpty()){											
			if(myStack.get(myStack.size() - 1).equals("TEXT") || myStack.get(myStack.size() - 1).equals("DATE") || myStack.get(myStack.size() - 1).equals("DOC") || myStack.get(myStack.size() - 1).equals("DOCNO") || myStack.get(myStack.size() - 1).equals("HEADLINE") || myStack.get(myStack.size() - 1).equals("LENGTH") || myStack.get(myStack.size() - 1).equals("P")) {
				relevant = 1;
			} else {
				relevant = 0;
			}
		}

		//Return completed relevant tag
		return new Token(Token.CLOSE, closeTag, yyline, yycolumn, relevant);
	}
}

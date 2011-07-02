# CSVParser

## About
CSVParser is a Cocoa class that parses CSV string.

## Usage
	NSString *source = @"comma-separeted string is here";
	CVSParser *parser = [CVSParser parser];
	NSArray *rows = [parser parseCSVString:source];

## License
[The MIT License](http://www.opensource.org/licenses/mit-license.php)

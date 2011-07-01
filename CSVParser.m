// 
// Copyright (c) 2011 Shun Takebayashi
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 

#import "CSVParser.h"

@interface CSVParser ()

- (NSString *)removeCarriageReturnFromString:(NSString *)string;
- (NSArray *)tokenizeCSVString:(NSString *)csvString;
- (NSArray *)organizeCSVTokens:(NSArray *)tokens;

@end

@implementation CSVParser

+ (CSVParser *)parser {
	return [[[self alloc] init] autorelease];
}

- (NSArray *)parseCSVString:(NSString *)csvString {
	NSArray *tokens = [self tokenizeCSVString:[self removeCarriageReturnFromString:csvString]];
	NSArray *rows = [self organizeCSVTokens:tokens];
	return rows;
}

- (NSString *)removeCarriageReturnFromString:(NSString *)string {
	NSMutableString *temp = [NSMutableString stringWithString:string];
	[temp replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:0 range:NSMakeRange(0, [temp length])];
	[temp replaceOccurrencesOfString:@"\r" withString:@"\n" options:0 range:NSMakeRange(0, [temp length])];
	return temp;
}

- (NSArray *)tokenizeCSVString:(NSString *)csvString {
	NSMutableArray *tokens = [NSMutableArray array];
	NSScanner *scanner = [NSScanner scannerWithString:csvString];
	NSCharacterSet *specialCharacters = [NSCharacterSet characterSetWithCharactersInString:@",\"\n"];
	while (![scanner isAtEnd]) {
		NSString *token = nil;
		[scanner scanUpToCharactersFromSet:specialCharacters intoString:&token];
		if (token) {
			[tokens addObject:token];
		}
		if (![scanner isAtEnd]) {
			NSUInteger location = [scanner scanLocation];
			NSString *character = [csvString substringWithRange:NSMakeRange(location, 1)];
			[tokens addObject:character];
			[scanner setScanLocation:location + 1];
		}
	}
	return tokens;
}

- (NSArray *)organizeCSVTokens:(NSArray *)tokens {
	NSMutableArray *rows = [NSMutableArray array];
	NSMutableArray *columns = [NSMutableArray array];
	BOOL isQuoted = NO;
	NSString *columnString = nil;
	for (NSString *token in tokens) {
		if (isQuoted) {
			if ([token isEqualToString:@"\""]) {
				isQuoted = NO;
			}
			else {
				if (!columnString) {
					columnString = @"";
				}
				columnString = [columnString stringByAppendingString:token];
			}
		}
		else {
			if ([token isEqualToString:@"\n"]) {
				[columns addObject:columnString];
				[rows addObject:columns];
				columns = [NSMutableArray array];
				columnString = nil;
			}
			else if ([token isEqualToString:@","]) {
				[columns addObject:columnString ? columnString : @""];
				columnString = nil;
			}
			else if ([token isEqualToString:@"\""]) {
				isQuoted = YES;
				if (columnString) {
					columnString = [columnString stringByAppendingString:@"\""];
				}
				else {
					columnString = @"";
				}
			}
			else {
				if (!columnString) {
					columnString = @"";
				}
				columnString = [columnString stringByAppendingString:token];
			}
		}
	}
	if (columnString) {
		[columns addObject:columnString];
		[rows addObject:columns];
	}
	return rows;
}

@end

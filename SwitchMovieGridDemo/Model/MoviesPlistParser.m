//
//  MoviesPlistParser.m
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/23/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import "MoviesPlistParser.h"

@interface MoviesPlistParser()<NSXMLParserDelegate>
@property (nonatomic, assign) BOOL shoulCollectCurrentElement;
@property (nonatomic, strong) NSMutableArray *moviesURL;
@end

@implementation MoviesPlistParser

- (id)init {
    if (self = [super init]) {
        _moviesURL = [NSMutableArray array];
    }
    
    return self;
}

+ (NSArray *)moviesURL {
    MoviesPlistParser *plistParser = [self new];
    
    NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"nyt_movie_data" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = plistParser;
    parser.shouldProcessNamespaces = YES;
    parser.shouldResolveExternalEntities = NO;
    [parser parse];
    
    return [NSArray arrayWithArray:plistParser.moviesURL];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"string"]) {
        self.shoulCollectCurrentElement = YES;
    }
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.shoulCollectCurrentElement) {
        [self.moviesURL addObject:string];
        self.shoulCollectCurrentElement = NO;
    }
}

@end

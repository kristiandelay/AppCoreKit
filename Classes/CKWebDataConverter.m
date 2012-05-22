//
//  CKWebDataConverter.m
//  CloudKit
//
//  Created by Guillaume Campagna on 12-05-18.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKWebDataConverter.h"
#import <UIKit/UIKit.h>
#import "CXMLDocument.h"
#import <VendorsKit/VendorsKit.h>
#import "RegexKitLite.h"

@implementation CKWebDataConverter

static NSMutableDictionary *dictionnary;

+ (void)initialize {
    dictionnary = [[NSMutableDictionary alloc] init];
    
    [self addConverter:^id(NSData *data, NSURLResponse *response) {
        NSStringEncoding responseEncoding;
        if (response.textEncodingName)
             responseEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName));
        else 
            responseEncoding = NSUTF8StringEncoding;
        
        return [[[NSString alloc] initWithData:data encoding:responseEncoding] autorelease];
    } forMIMEPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject hasPrefix:@"text/"];
    }]];
    
    [self addConverter:^id(NSData *data, NSURLResponse *response) {
        return [UIImage imageWithData:data];
    } forMIMEPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject hasPrefix:@"image/"];
    }]];
    
    [self addConverter:^id(NSData *data, NSURLResponse *response) {
        return [data objectFromJSONData];
    } forMIMEPredicate:[NSPredicate predicateWithFormat:@"self = \"application/json\""]];
    
    [self addConverter:^id(NSData *data, NSURLResponse *response) {
        return [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
    } forMIMEPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isMatchedByRegex:@"(application|text)/xml"];
    }]];
}

+ (void)addConverter:(id (^)(NSData * data, NSURLResponse *response))converter forMIMEPredicate:(NSPredicate*)predicate {
    [dictionnary setObject:converter forKey:predicate];
}

+ (id)convertData:(NSData *)data fromResponse:(NSURLResponse *)response {
    NSString *MIMEType = response.MIMEType;
    
    id (^converter)(NSData *, NSURLResponse*) = nil;
    for (NSPredicate *predicate in dictionnary) {
        if ([predicate evaluateWithObject:MIMEType]) {
            converter = [dictionnary objectForKey:predicate];
            break;
        }
    }
    
    if (converter) {
        id result = converter(data, response);
        if (result)
            return result;
        else
            return data;
    }
    else
        return data;
}

@end

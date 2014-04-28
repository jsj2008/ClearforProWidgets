// Clear for ProWidgets
// Created by Julian (insanj) Weiss (c) 2014
// Source and license fully available on GitHub.

#import "CWViewController.h"
#import "CWWidget.h"
#import "CWItemListValue.h"

@implementation CWViewController

- (void)load {
	[self loadPlist:@"CWAddItem"];
	[self setupClearLists];

	[self setItemValueChangedEventHandler:self selector:@selector(itemValueChangedEventHandler:oldValue:)];
	[self setSubmitEventHandler:self selector:@selector(submitEventHandler:)];
}

// Load list values from SQLite database
- (void)setupClearLists {
	NSArray *lists = [[[CWDynamicReader alloc] init] listsFromDatabase];
	NSArray *values = [NSArray arrayWithArray:lists];

	CWItemListValue *item = (CWItemListValue *)[self itemWithKey:@"list"];
	[item setListItemTitles:[lists arrayByAddingObject:@"Create List..."] values:[values arrayByAddingObject:@(NSIntegerMax)]];

	NSString *savedValue = [[NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.clearforprowidgets.plist"]] objectForKey:@"defaultList"];
	if ([lists containsObject:savedValue]) {
		item.value = savedValue;
	}
}

- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue {
	if ([item.key isEqualToString:@"list"]) {
		NSArray *value = (NSArray *)item.value;

		// If the value (integer association) is equal to the last value in the list, prompt
		// to Create. Since the last value inserted is NSIntegerMax, if the item that's tapped
		// is also NSIntegerMax, then it's clear we should Create.
		if ([value[0] isEqual:[[(PWWidgetItemListValue *)item listItemValues] lastObject]]) {
			__block NSArray *oldListValue = oldValue;
			[self.widget prompt:@"What would you like to name your new Clear list?" title:@"Create List" buttonTitle:@"Add" defaultValue:nil style:UIAlertViewStylePlainTextInput completion:^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
				if (cancelled) {
					[item setValue:oldListValue];
				}

				else {
					[self createList:firstValue];
				}
			}];
		}
	}
}

- (void)createList:(NSString *)name {
	NSString *scheme = [@"clearapp://list/create?listName=" stringByAppendingString:name];

	CWLOG(@"[ClearForProWidgets] Creating list with using URL-scheme [%@]", scheme);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[scheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (void)submitEventHandler:(NSDictionary *)values {
	[self.widget dismiss];

	NSString *list = values[@"list"][0];
	NSString *task = values[@"task"];
	NSString *scheme = [NSString stringWithFormat:@"clearapp://task/create?listName=%@&taskName=%@", list, task];

	NSURL *schemeURL = [NSURL URLWithString:[scheme stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	CWLOG(@"[ClearForProWidgets] Creating task with values [%@] using URL-scheme [%@]...", values, scheme);
	[OBJCIPC sendMessageToAppWithIdentifier:@"com.realmacsoftware.clear" messageName:@"CWIPC.Create.Task" dictionary:@{ @"schemeURL" : schemeURL } replyHandler:^(NSDictionary *response) { 
		CWLOG(@"[ClearForProWidgets] Created task in Clear with response: %@", response); 
	}];
}

@end

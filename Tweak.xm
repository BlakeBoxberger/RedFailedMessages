static NSUserDefaults *settings;
static BOOL donation = YES;

static void nz9_prefChanged() {
  if (settings) {
    [settings release];
  }
  settings = [[NSUserDefaults  alloc] initWithSuiteName:@"com.neinzedd9.RedFailedMessage"];
	donation = [settings boolForKey: @"thankYouDisplayed"];
}

typedef NS_ENUM(NSUInteger, CKBalloonViewColor) {
	CKBalloonViewColorGreen,
	CKBalloonViewColorBlue,
	CKBalloonViewColorWhite,
	CKBalloonViewColorRed,
	CKBalloonViewColorWhiteAgain,
	CKBalloonViewColorBlack
};

@interface CKChatItem : NSObject

@end

@interface CKBalloonChatItem : CKChatItem

@property (nonatomic, assign, readonly) BOOL failed;

@end

@interface CKMessagePartChatItem : CKBalloonChatItem

@end

%hook CKMessagePartChatItem

- (CKBalloonViewColor)color {
	if(self.failed) {
		if(!donation) {
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enjoying my tweak, RedFailedMessage?"
																																		 message:@"Please consider donating so I can continue to develop tweaks like this!\n-NeinZedd9 <3"
																															preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel
				handler:^(UIAlertAction *action) {}];
			UIAlertAction *donateAction = [UIAlertAction actionWithTitle:@"Donate" style:UIAlertActionStyleDefault
				handler:^(UIAlertAction *action) {
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/neinzedd"]];
				}];
			[alert addAction:defaultAction];
			[alert addAction:donateAction];
			[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
			donation = YES;
			[settings setBool:YES forKey:@"thankYouDisplayed"];
		}
		return CKBalloonViewColorRed;
	}
	else {
		return %orig;
	}
}

%end


%ctor {
	settings = [[NSUserDefaults alloc] initWithSuiteName: @"com.neinzedd9.RedFailedMessage"];
  [settings registerDefaults:@{
    @"thankYouDisplayed": @NO
  }];
	%init;
	nz9_prefChanged();
}

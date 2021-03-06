//
//  UIAlertViewInputSection.m
//  KeyChain
//
//  Created by softphone on 14/02/12.
//  Copyright (c) 2012 SOFTPHONE. All rights reserved.
//

#import "UIAlertViewInputSection.h"
#import "KeyEntity.h"

@interface UIAlertViewInputSection (/*Private*/) 

@property (nonatomic,copy) void (^clickedButtonAtIndexBlock)( UIAlertViewInputSection *alertView, NSInteger buttonIndex) ;

- (BOOL)isSectionAware:(NSString *)key;
- (void)processInputText:(UIAlertView*)alert;
@end

@implementation UIAlertViewInputSection

@synthesize groupName, groupPrefix;
@synthesize clickedButtonAtIndexBlock;

static UIAlertViewInputSection *currentDelegate;

+ (UIAlertView *)alertViewWithBlock:(void(^)( UIAlertViewInputSection *alertView, NSInteger buttonIndex))clickedButtonAtIndexBlock
{
    if( currentDelegate==nil ) {
        currentDelegate = [[UIAlertViewInputSection alloc] init];
    }
    currentDelegate.clickedButtonAtIndexBlock = clickedButtonAtIndexBlock;
    
    
    UIAlertView *alert_ = [[UIAlertView alloc] 
              initWithTitle:NSLocalizedString(@"AlertViewInputSection.alertTitle", @"add new Item")
              message:NSLocalizedString(@"AlertViewInputSection.alertMessage", @"add item message") 
              delegate:currentDelegate
              cancelButtonTitle:@"Cancel"
              otherButtonTitles:@"OK", nil];
    // Name field
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
    tf.tag = 100;
    tf.keyboardType = UIKeyboardTypeEmailAddress;
    tf.placeholder = NSLocalizedString(@"AlertViewInputSection.alertPlaceholder", @"add item placeholder");
    [tf setBackgroundColor:[UIColor whiteColor]]; 
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.keyboardType = UIKeyboardTypeAlphabet;
    tf.keyboardAppearance = UIKeyboardAppearanceAlert;
    tf.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters; //UITextAutocapitalizationTypeWords;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    [tf becomeFirstResponder];
    [alert_ addSubview:tf];	
    
    return alert_;
    
}


- (BOOL)isSectionAware:(NSString *)key {

    static  NSString * _REGEXP = @"(\\w+)[-@/]";
    
    
    NSPredicate *predicate = 
        [NSPredicate predicateWithFormat:@"SELF MATCHES %@",  _REGEXP];
    
    BOOL result = [predicate evaluateWithObject:key];
    
    
    return result;
}


- (void)processInputText:(UIAlertView *)alert {
 
        groupName = nil;
        groupPrefix = nil;

        if (alert == nil ) {
            return;
        }
        
        UITextField *tf = (UITextField*)[alert viewWithTag:100];
        
        NSString *trimmed = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if( [trimmed length] == 0 ) {
            return ;
        }

        if( [self isSectionAware:trimmed] ) {
            
            groupPrefix = trimmed;
            groupName = [KeyEntity sectionNameFromPrefix:groupPrefix trim:NO];
        }
        else {
            groupPrefix = [trimmed stringByAppendingString:@"-"];
            groupName = trimmed;
        }
}

#pragma - memory management

- (void)dealloc 
{

    NSLog(@" UIAlertViewInputSection.dealloc" );
}

#pragma mark UIAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self processInputText:alertView];
    
    if ( self.clickedButtonAtIndexBlock!=nil) {
        self.clickedButtonAtIndexBlock( self, buttonIndex);
    }
        
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
//- (void)alertViewCancel:(UIAlertView *)alertView;

//- (void)willPresentAlertView:(UIAlertView *)alertView;  // before animation and showing view
//- (void)didPresentAlertView:(UIAlertView *)alertView;  // after animation

//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

// Called after edits in any of the default fields added by the style
//- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView ;


@end

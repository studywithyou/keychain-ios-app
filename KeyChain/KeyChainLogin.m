//
//  KeyChainLogin.m
//  KeyChain
//
//  Created by softphone on 16/01/11.
//  Copyright 2011 SOUL. All rights reserved.
//

#import "KeyChainLogin.h"
#import "WEPopoverController.h"
#import "InfoViewController.h"
#import "AccountCredential.h"

#define TAG_FOR_LOGIN_BUTTON 5

@interface KeyChainLogin(Private)


- (BOOL)loginToSystem;
- (BOOL)changePassword;
- (void)doModal:(UIViewController *)root;
- (void)getNewPassword;


@end

@implementation KeyChainLogin

@synthesize txtPassword;
@synthesize parent=parent_;

@synthesize btnVersion=btnVersion_;
@synthesize btnInfo=btnInfo_;

@synthesize popoverController;
@synthesize toolBar;

#pragma mark - private implementation

- (BOOL)loginToSystem {
	
	NSString *p = [AccountCredential sharedCredential].password;
	if ( p==nil ) {
		[AccountCredential sharedCredential].password = txtPassword.text;
		self.txtPassword.text = @"";
		self.txtPassword.placeholder = NSLocalizedString(@"login.confirmPassword", @"");
		return NO;
	}
	
	if ([p compare: txtPassword.text] != 0 ) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password doesn't match!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
        
        self.txtPassword.text = @"";
		return NO;
		
	}

	[self.parent.view setHidden:NO];
	[self.parent dismissModalViewControllerAnimated:YES];
	
	//[self.parentViewController.view setHidden:NO];
	//[[self.parentViewController modalViewController] dismissModalViewControllerAnimated:YES];
	return YES;
}


- (void) getNewPassword {

    self.txtPassword.text = @"";
    self.txtPassword.placeholder = NSLocalizedString(@"login.newPassword", @"");
    changePasswordStep_ = GETNEWPASSWORD;
    
}

- (BOOL)changePassword {

    static NSString *tmpPassword_;
    
    BOOL result = NO;
    
    //
    // STEP 1 - CHECK PASSWORD 
    //
    
    //
    // STEP 2 - GET NEW PASSWORD 
    //
    
    //
    // STEP 3 - RETYPE NEW PASSWORD 
    //
    
    //
    // STEP 4 - CHECK NEW PASSWORD 
    //
    
    switch (changePasswordStep_) {
        case CHECKPASSWORD:
        {
            NSString *p = [AccountCredential sharedCredential].password;

            if ([p compare: txtPassword.text] != 0 ) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password doesn't match!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
                
                
            }
            else {
                
                [self getNewPassword];
            }
            
        }
            break;
        case GETNEWPASSWORD:
        {
            tmpPassword_ = [self.txtPassword.text copy];
            
            self.txtPassword.text = @"";
            self.txtPassword.placeholder = NSLocalizedString(@"login.confirmNewPassword", @"");
            changePasswordStep_ = CHECKNEWPASSWORD;
        }
            break;
        case CHECKNEWPASSWORD:
        {
            
            if ([tmpPassword_ compare: self.txtPassword.text] != 0 ) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password doesn't match!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];

                [self getNewPassword];
                
            }
            else {
                
                [AccountCredential sharedCredential].password = tmpPassword_;
                result = YES;
                [self.navigationController popViewControllerAnimated:YES]; 
            }

        }
            break;
        default:
            result = YES;
            break;
    }
    
	return result;
    
}

- (void)doModal:(UIViewController *)root {
    
    self.title = @"";
    
    changePasswordStep_ = NONE;
    
	[root.view setHidden:YES];
    
	//self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
    [root presentModalViewController:self animated:YES];
    
    self.parent = root;
}


#pragma mark - KeyChainLogin 


+ (void)doModal:(UIViewController *)root {
    
    KeyChainLogin *login = [[KeyChainLogin alloc] initWithNibName:@"KeyChainLogin" bundle:nil] ;
    [login	doModal:root];
    
}

- (id)initForChangePassword  {
    
    if( self = [super initWithNibName:@"KeyChainLogin" bundle:nil]  ) {
        changePasswordStep_ = CHECKPASSWORD;
        self.title = @"Change Password";
        
        UIView *button = [self.view viewWithTag:TAG_FOR_LOGIN_BUTTON];
        if( button!=nil ) {
            [button setHidden:YES];
        }
        return self;
    }
    return nil;
}


- (IBAction)info:(id)sender  {
    

    
	if (!self.popoverController) {
		
        InfoViewController *contentViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
		
        contentViewController.contentSizeForViewInPopover = CGSizeMake(270, 300);
        
        self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
		
        //self.popoverController.delegate = self;

        /*
		self.popoverController.passthroughViews = 
            [NSArray arrayWithObject:self.navigationController.navigationBar];
		
         [self.popoverController presentPopoverFromBarButtonItem:sender 
									   permittedArrowDirections:UIPopoverArrowDirectionDown 
													   animated:YES];
         */
      
    } 

     [self.popoverController presentPopoverFromBarButtonItem:sender 
                                                     toolBar:self.toolBar
                                    permittedArrowDirections:UIPopoverArrowDirectionDown 
                                                    animated:YES];
}

- (IBAction)login:(id)sender {

	[self loginToSystem];
}

#pragma mark -
#pragma mark inherit from UITextFieldDelegate
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (changePasswordStep_ != NONE ) {
        return [self changePassword];
    }
    return [self loginToSystem];
}

#pragma mark inherit from UIViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    NSString *_bundleVersion = [AccountCredential sharedCredential].bundleVersion;

	txtPassword.delegate = self;
    
    NSLog(@"bundle version [%@]", _bundleVersion );
    
    NSString *versionTitle = [NSString stringWithFormat:self.btnVersion.title, _bundleVersion];
    
    self.btnVersion.title = versionTitle;
    

}

//
-(void)viewDidAppear:(BOOL)animated {

    __block KeyChainLogin *_self = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if ( [[AccountCredential sharedCredential] checkAndUpdateCurrentVersion] ) {
            
            [_self info:_self.btnInfo];
        }
    });
    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end

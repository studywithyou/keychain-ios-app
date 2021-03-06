//
//  TextDataEntryCell.h
//  TableViewDataEntry
//
//  Created by Fabrizio Guglielmino on 10/09/10.
//  Copyright 2010 Infit S.r.l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDataEntryCell.h"

@interface TextDataEntryCell : BaseDataEntryCellWithResponder <UITextFieldDelegate> {
	UITextField *__UIXML_WEAK textField;
}

@property (nonatomic, UIXML_WEAK) IBOutlet UITextField *textField;

@end

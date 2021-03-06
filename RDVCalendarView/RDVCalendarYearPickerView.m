//
//  RDVCalendarYearPickerView.m
//  RDVCalendar
//
// Copyright (c) 2014 Douglas Drouillard
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
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RDVCalendarYearPickerView.h"

NSInteger const YearsInRange = 12;
NSInteger const NumYearsToGoBackToStartRange = 5;

@interface RDVCalendarYearPickerView (){
    NSMutableArray *_visibleCells;
}

/**
 * The current year the range of years shown is being anchored around.
 */
@property (nonatomic) NSDateComponents *anchorYearForDisplayedRange;

@property (nonatomic) NSDateComponents *currentYear;

@end

@implementation RDVCalendarYearPickerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _visibleCells = [[NSMutableArray alloc] initWithCapacity:YearsInRange];
        
        _title = [[UILabel alloc]initWithFrame:CGRectMake(0,0, self.bounds.size.width, 150)];
        _title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_title];
        
        _backButton = [[UIButton alloc] init];
        [_backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_backButton setTitle:@"Prev" forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(showPreviousYear)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        _forwardButton = [[UIButton alloc] init];
        [_forwardButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_forwardButton setTitle:@"Next" forState:UIControlStateNormal];
        [_forwardButton addTarget:self action:@selector(showNextYear)
                 forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_forwardButton];
        
        self.backgroundColor = [UIColor whiteColor];
        
        _currentYear = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];

        
        [self configureSwipeEvents];
    }
    
    return self;
}


- (void)layoutSubviews
{
    
    CGSize viewSize = self.frame.size;
    CGSize headerSize = CGSizeMake(viewSize.width, 60.0f);
    CGFloat backButtonWidth = MAX([[self backButton] sizeThatFits:CGSizeMake(100, 50)].width, 44);
    CGFloat forwardButtonWidth = MAX([[self forwardButton] sizeThatFits:CGSizeMake(100, 50)].width, 44);
    
    CGSize previousMonthButtonSize = CGSizeMake(backButtonWidth, 50);
    CGSize nextMonthButtonSize = CGSizeMake(forwardButtonWidth, 50);
    CGSize titleSize = CGSizeMake(viewSize.width - previousMonthButtonSize.width - nextMonthButtonSize.width - 10 - 10,
                                  50);
    
    // Layout header view
    [self.backButton setFrame:CGRectMake(10, roundf(headerSize.height / 2 - previousMonthButtonSize.height / 2),
                                           previousMonthButtonSize.width, previousMonthButtonSize.height)];
    
    [self.title setFrame:CGRectMake(roundf(headerSize.width / 2 - titleSize.width / 2),
                                           roundf(headerSize.height / 2 - titleSize.height / 2),
                                           titleSize.width, titleSize.height)];
    
    [self.forwardButton setFrame:CGRectMake(headerSize.width - 10 - nextMonthButtonSize.width,
                                              roundf(headerSize.height / 2 - nextMonthButtonSize.height / 2),
                                              nextMonthButtonSize.width, nextMonthButtonSize.height)];
    
    CGFloat yearCellWidth = 0;
    yearCellWidth = roundf(viewSize.width / 4);
    
    CGFloat yearRangeHeaderEndY = CGRectGetMaxY([self.title frame]);
    CGFloat yearCellHeight = 0;
    
    if (viewSize.width > viewSize.height) {
        yearCellHeight = roundf((viewSize.height - yearRangeHeaderEndY) / 3);
    }
    else {
        yearCellHeight = roundf((viewSize.height - yearRangeHeaderEndY) / 4);
    }
    
    //clear existing year cells
    for (RDVCalendarPickerCell *visibleCell in _visibleCells) {
        [visibleCell removeFromSuperview];
    }
    
    [_visibleCells removeAllObjects];
    
    
    int row = 0;
    int column = 0;
    
    
    //Set up years in grid format
    for (NSInteger year = [self startYearOfRange]; year <= [self endYearOfRange]; year++ ){

        CGRect yearCellFrame = CGRectMake(column * yearCellWidth, yearRangeHeaderEndY + row * yearCellHeight, yearCellWidth, yearCellHeight);
        RDVCalendarPickerCell *yearCell = [[RDVCalendarPickerCell alloc] initWithFrame:yearCellFrame];
        
        NSString *labelText = [NSString stringWithFormat:@"%ld", (long)year];
                
        [yearCell setTitle:labelText forState:UIControlStateNormal];
        [yearCell setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [yearCell setTitleColor:[UIColor whiteColor] forState: UIControlStateSelected];
        [yearCell setTitleColor:[UIColor whiteColor] forState: UIControlStateHighlighted];
        [yearCell.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [yearCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_normalYearColor] forState: UIControlStateNormal];
        [yearCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_selectedYearColor] forState: UIControlStateSelected ];
        [yearCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_selectedYearColor] forState: UIControlStateHighlighted];
        [yearCell addTarget:self action:@selector(selectedYear:) forControlEvents:UIControlEventTouchUpInside];
        
        [_visibleCells addObject:yearCell];
        
        [self addSubview:yearCell];
        
        //Reset to beginning of next row
        if (column == 3) {
            column = 0;
            
            row++;
        } else {
            column++;
        }
    }
    
    [self reloadData];

}

- (void) reloadData
{
    
    
//    NSDateComponents *dateComponent = [NSDateComponents alloc];
//    [dateComponent setCalendar:calendar];
//    [dateComponent setYear:displayedYear];
//    [dateComponent setMonth:month];
//    
//    monthCell.dateComponents = dateComponent;
//    
//    NSString *labelText = [monthCell getDisplayMonth];
//    
//    [monthCell setTitle:labelText forState:UIControlStateNormal];
    

    //re-use existing year cells
    NSInteger indexOfCell = 0;
    NSCalendar *calendar = [self calendar];
    
    for (NSInteger year = self.startYearOfRange; year <= self.endYearOfRange; year++ ){
        RDVCalendarPickerCell *yearCell = _visibleCells[indexOfCell];
        [yearCell reset];
        [yearCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_normalYearColor] forState: UIControlStateNormal];
        
        NSDateComponents *dateComponent = [NSDateComponents alloc];
        [dateComponent setCalendar:calendar];
        [dateComponent setYear:year];
        [dateComponent setMonth:1];
        
        yearCell.dateComponents = dateComponent;
        
        NSString *labelText = [NSString stringWithFormat:@"%ld", year];
        
        [yearCell setTitle:labelText forState:(UIControlStateNormal)];
        
        //if actual year
        if(year == [_selectedYear year]){
            [yearCell setSelected:YES];
        }
        else if(year == [_currentYear year]){
            [yearCell setBackgroundImage:[RDVCalendarPickerCell imageFromColor:_currentYearColor] forState: UIControlStateNormal];
        }
     
        
        indexOfCell++;
    }
}


#pragma mark - Updating Year shown

- (NSInteger) startYearOfRange
{
    return [_anchorYearForDisplayedRange year] - NumYearsToGoBackToStartRange;
}

- (NSInteger) endYearOfRange
{
    return self.startYearOfRange + YearsInRange - 1;
}

- (void) updateTitle:(NSInteger)year
{
    _title.text = [NSString stringWithFormat:@"%ld-%ld", self.startYearOfRange, self.endYearOfRange];
}

- (void) setAnchorYearForDisplayedRange:(NSDateComponents *)year
{
    // need to make a copy here because the displayed year is manipulated
    // through navigation. However, those changes might be abandoned by the user
    _anchorYearForDisplayedRange = [year copy];
    [self updateTitle: [_anchorYearForDisplayedRange year]];
}

- (void) setSelectedYear:(NSDateComponents *)year
{
    _selectedYear = year;
    [self setAnchorYearForDisplayedRange:_selectedYear];
    
}

#pragma mark - Navigation

- (void) showNextYear
{
    [self.anchorYearForDisplayedRange setYear:[self.anchorYearForDisplayedRange year] + YearsInRange];
    [self reloadData];
}

- (void) showPreviousYear
{
    [self.anchorYearForDisplayedRange setYear:[self.anchorYearForDisplayedRange year] - YearsInRange];
    [self reloadData];
}

#pragma mark - Configure Swipe Events

-(void) configureSwipeEvents
{
    // support for swiping forward/back year ranges
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGestureRecognizer];

}

- (void)swipeLeft:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self showNextYear];
    }];
}

- (void)swipeRight:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [self showPreviousYear];
    }];
}

#pragma mark - Messaging Delegate

- (void) selectedYear:(id)sender
{
    RDVCalendarPickerCell *yearSelectedCell = (RDVCalendarPickerCell *) sender;
    NSDateComponents* yearSelected = yearSelectedCell.dateComponents;
    
    [_visibleCells makeObjectsPerformSelector:@selector(reset)];
    
    [yearSelectedCell setSelected:YES];
    _selectedYear = yearSelected;
    
    NSLog(@"This is year returned %@", yearSelected);
    
    if ([self.delegate respondsToSelector:@selector(yearPickerView:didSelectYear:)]) {
        [self.delegate yearPickerView:self didSelectYear:yearSelected];
    }
}

#pragma mark - Helper methods

- (NSCalendar *)calendar
{
    static NSCalendar *calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    return calendar;
}

@end


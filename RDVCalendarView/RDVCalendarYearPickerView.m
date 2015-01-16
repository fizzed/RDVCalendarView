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

@end


@implementation RDVCalendarYearPickerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _visibleCells = [[NSMutableArray alloc] initWithCapacity:YearsInRange];
        
        _rangeTitle = [[UILabel alloc]initWithFrame:CGRectMake(0,0, self.bounds.size.width, 150)];
        _rangeTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_rangeTitle];
        
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
    
    [self.rangeTitle setFrame:CGRectMake(roundf(headerSize.width / 2 - titleSize.width / 2),
                                           roundf(headerSize.height / 2 - titleSize.height / 2),
                                           titleSize.width, titleSize.height)];
    
    [self.forwardButton setFrame:CGRectMake(headerSize.width - 10 - nextMonthButtonSize.width,
                                              roundf(headerSize.height / 2 - nextMonthButtonSize.height / 2),
                                              nextMonthButtonSize.width, nextMonthButtonSize.height)];
    
    CGFloat yearCellWidth = 0;
    yearCellWidth = roundf(viewSize.width / 4);
    
    CGFloat yearRangeHeaderEndY = CGRectGetMaxY([self.rangeTitle frame]);
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
        
        if(year == _selectedYear){
            [yearCell setSelected:YES];
        }
        
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

}

- (NSInteger) startYearOfRange
{
    return _anchorYear - NumYearsToGoBackToStartRange;
}

- (NSInteger) endYearOfRange
{
    return self.startYearOfRange + YearsInRange - 1;
}

- (void) updateTitle:(NSInteger)year
{
    _rangeTitle.text = [NSString stringWithFormat:@"%ld-%ld", self.startYearOfRange, self.endYearOfRange];
}

- (void) reloadData
{
    
    //re-use existing year cells
    NSInteger indexOfCell = 0;
    for (NSInteger year = self.startYearOfRange; year <= self.endYearOfRange; year++ ){
        RDVCalendarPickerCell *yearCell = _visibleCells[indexOfCell];
        [yearCell reset];
        
        if(year == _selectedYear){
            [yearCell setSelected:YES];
        }
        
        NSString *labelText = [NSString stringWithFormat:@"%ld", year];
        
       [yearCell setTitle:labelText forState:(UIControlStateNormal)];
        
        indexOfCell++;
    }
}

-(void) setAnchorAndSelectedYear:(NSInteger) year{
    [self setSelectedYear:year];
    [self setAnchorYear:year];
}

//-(void) setAnchorYear:(NSInteger)year
//{
//    _currentAnchorYear = year;
//    [self updateTitle:year];
//}

- (void) showNextYear
{
    [self setAnchorYear:self.anchorYear + YearsInRange];
    [self reloadData];
}

- (void) showPreviousYear
{
    [self setAnchorYear:self.anchorYear - YearsInRange];
    [self reloadData];
}


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

- (void) selectedYear:(id)sender
{
    RDVCalendarPickerCell *yearSelectedCell = (RDVCalendarPickerCell *) sender;
    NSInteger yearSelected = (NSInteger) [yearSelectedCell.titleLabel.text intValue];
    
    [_visibleCells makeObjectsPerformSelector:@selector(reset)];
    
    [yearSelectedCell setSelected:YES];
    [self setSelectedYear:yearSelected];
    
    if ([self.delegate respondsToSelector:@selector(yearPickerView:didSelectYear:)]) {
        [self.delegate yearPickerView:self didSelectYear:yearSelected];
    }
}

@end


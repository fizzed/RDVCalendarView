//
//  RDVCalendarPickerCell.m
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

#import "RDVCalendarPickerCell.h"

@implementation RDVCalendarPickerCell

-(NSString *) getDisplayMonth
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM";
    [self.dateComponents setDay:1];
    
    NSDate *date = [self.dateComponents.calendar dateFromComponents:self.dateComponents];
    
    NSString *formattedMonth = [[NSString alloc] initWithString:[formatter stringFromDate:date]];
    return formattedMonth;
}





-(NSString *) getDisplayYear
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy";
    [self.dateComponents setDay:1];
    
    NSDate *date = [self.dateComponents.calendar dateFromComponents:self.dateComponents];
    //NSDate *date = [year.calendar dateFromComponents:year];
    
   NSString *formattedYear = [[NSString alloc] initWithString:[formatter stringFromDate:date]];
   
    return formattedYear;
}


-(void) reset {
    [self setHighlighted:NO];
    [self setSelected:NO];
}

+ (UIImage *) imageFromColor:(UIColor *)color {
    //default to white color
    color = color ? color : [UIColor whiteColor];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

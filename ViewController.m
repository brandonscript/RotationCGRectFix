//
//  ViewController.m
//  RotationCGRectFix
//
//  Created by Brandon on 12/5/14.
//  Copyright (c) 2014 Brandon. All rights reserved.
//

#import "ViewController.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIView *imageView;
@property (strong, nonatomic) IBOutlet UIView *cropView;
- (IBAction)gestureRecognized:(UIRotationGestureRecognizer *)gesture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gestureRecognized:(UIRotationGestureRecognizer *)gesture {
    CGFloat maxRotation = 40;
    CGFloat rotation = gesture.rotation;
    CGFloat currentRotation = atan2f(_imageView.transform.b, _imageView.transform.a);;
    
    NSLog(@"%0.4f", RADIANS_TO_DEGREES(rotation));
    if ((currentRotation > DEGREES_TO_RADIANS(maxRotation) && rotation > 0) || (currentRotation < DEGREES_TO_RADIANS(-maxRotation) && rotation < 0)) {
        return;
    }
    
    CGAffineTransform rotationTransform = CGAffineTransformRotate(_imageView.transform, rotation);
    CGPoint center = _imageView.center;
    _imageView.transform = CGAffineTransformConcat(_imageView.transform, rotationTransform);
    gesture.rotation = 0.0f;
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = 1.0;
        
        if ((currentRotation > 0 && rotation > 0) || (currentRotation < 0 && rotation < 0))
            scale = 1 + fabs(scale * rotation);
        else if (currentRotation == 0)
            scale = 1;
        else
            scale = 1 - fabs(scale * rotation);
        NSLog(@"%0.4f", scale);

        CGAffineTransform sizeTransform = CGAffineTransformMakeScale(scale, scale);
        _imageView.transform = CGAffineTransformScale(_imageView.transform, scale, scale);
        _imageView.center = center;
    }
}

- (BOOL)rotatedView:(UIView*)rotatedView containsViewCompletely:(UIView*)cropView {
    
    CGPoint cropRotated[4];
    CGRect rotatedBounds = rotatedView.bounds;
    CGRect cropBounds = cropView.bounds;
    
    // Convert corner points of cropView to the coordinate system of rotatedView:
    cropRotated[0] = [cropView convertPoint:cropBounds.origin toView:rotatedView];
    cropRotated[1] = [cropView convertPoint:CGPointMake(cropBounds.origin.x + cropBounds.size.width, cropBounds.origin.y) toView:rotatedView];
    cropRotated[2] = [cropView convertPoint:CGPointMake(cropBounds.origin.x + cropBounds.size.width, cropBounds.origin.y + cropBounds.size.height) toView:rotatedView];
    cropRotated[3] = [cropView convertPoint:CGPointMake(cropBounds.origin.x, cropBounds.origin.y + cropBounds.size.height) toView:rotatedView];
    
    // Check if all converted points are within the bounds of rotatedView:
    return (CGRectContainsPoint(rotatedBounds, cropRotated[0]) &&
            CGRectContainsPoint(rotatedBounds, cropRotated[1]) &&
            CGRectContainsPoint(rotatedBounds, cropRotated[2]) &&
            CGRectContainsPoint(rotatedBounds, cropRotated[3]));
}

- (CGRect) boundingRectAfterRotatingRect: (CGRect) rect toAngle: (float) radians
{
    CGAffineTransform xfrm = CGAffineTransformMakeRotation(radians);
    CGRect result = CGRectApplyAffineTransform (rect, xfrm);
    
    return result;
}

@end

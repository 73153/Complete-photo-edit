//
//  UIImage+InPaint.m
//  computer
//
//  Created by Nate Parrott on 5/10/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#import "UIImage+InPaint.h"
#import <opencv2/highgui/ios.h>
#import <opencv2/core/core_c.h>
#import "inpaint.h"

@implementation UIImage (InPaint)

+ (void)_testInPainting {
    UIImage *img = [UIImage imageNamed:@"inpaint-test.png"];
    UIImage *mask = [UIImage imageNamed:@"inpaint-mask.png"];
    UIImage *result = [img inpaintWithMask:mask];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"inpaint.png"];
    [UIImagePNGRepresentation(result) writeToFile:path atomically:YES];
    NSLog(@"%@", path);
}

- (UIImage *)inpaintWithMask:(UIImage *)maskUIImage {
//    IplImage* input_img=NULL , *maskimage=NULL,*distorted=NULL , *output_img=NULL,
//    *inpaint_mask_gray=NULL,*input_gray=NULL, *distorted_gray=NULL;
//
//    input_img=cvLoadImage(fileNameInput, 1);
//    
//    if (!input_img) {
//        printf("Could not load image file: %s\n",fileNameInput);
//        exit(1);
//    }
//
    IplImage *inputImage = [self iplImage];
//    size = cvGetSize(input_img);
//    height=size.height;
//    width=size.width;
    CvSize size = cvGetSize(inputImage);
//
//    distorted=cvLoadImage(fileNameMasked, 1);
    IplImage *distorted = [maskUIImage iplImage];
//
//    if (!distorted) {
//        printf("Could not load image file: %s\n",fileNameMasked);
//        exit(1);
//    }
//    
//    //Mask computation
//    maskimage=cvCreateImage(size,8,1);
//    cvZero(maskimage);
    IplImage *maskImage = cvCreateImage(size, 8, 1);
    cvZero(maskImage);
//    
//    input_gray=cvCreateImage(size,8,1);
//    cvZero(input_gray);
    IplImage *inputGray = cvCreateImage(size, 8, 1);
    cvZero(inputGray);
//    
//    distorted_gray=cvCreateImage(size,8,1);
//    cvZero(distorted_gray);
    IplImage *distortedGray = cvCreateImage(size, 8, 1);
    cvZero(distortedGray);
//    
//    cvCvtColor(distorted,maskimage,CV_BGR2GRAY);
    cvCvtColor(distorted, maskImage, CV_RGB2GRAY);
//    
//    for ( int i=0 ; i < height ; ++i )
//        for ( int j=0 ; j<width;  ++j )
//            if (cvGet2D(maskimage,i,j).val[0] !=255 )
//                cvSet2D(maskimage,i,j,cvScalar(0,0,0));
    for ( int i=0 ; i < size.height ; ++i ) {
        for ( int j=0 ; j<size.width;  ++j ) {
            if (cvGet2D(maskImage,i,j).val[0] !=255 ) {
                cvSet2D(maskImage,i,j,cvScalar(0,0,0));
            }
        }
    }
//    
//    //display images
//    cvNamedWindow("Original image", CV_WINDOW_AUTOSIZE);
//    cvShowImage("Original image",input_img);
//    
//    cvNamedWindow("MASK", CV_WINDOW_AUTOSIZE);
//    cvShowImage("MASK",distorted);
//    
//    // generate mask array from mask image
//    int channels=maskimage->nChannels;
//    int step = maskimage->widthStep/sizeof(uchar);
//    int ** mask;
//    mask = (int **) calloc(int(height),sizeof(int*));
//    for ( int i=0 ; i<width ; i++)
//        mask[i] = (int *) calloc(int(width),sizeof(int));
    int channels = maskImage->nChannels;
    int step = maskImage->widthStep/sizeof(uchar);
    int** mask = (int **)calloc(size.height,sizeof(int*));
    for (int i=0; i<size.height; i++) {
        mask[i] = (int *)calloc(size.width, sizeof(int));
    }
    
//    
//    printf("----------------------------------------------------------------------\n");
//    printf("\n");
//    printf("Computing, please wait, this operation may take several minutes...\n");
//    
//    data = (uchar *)maskimage->imageData;
    uchar *data = (uchar *)maskImage->imageData;
    for (int i=0; i<size.height; ++i) {
        for (int j=0; j<size.width; ++j) {
            if (data[i*step+j*channels] == 255) {
                mask[i][j] = 1;
            }
        }
    }
    
//    //Timer: tic, toc
//    tic = clock ();
//    for ( int i = 0 ; i < height ; ++i )
//        for ( int j = 0 ; j < width ; ++j )
//            if ( data[i*step+j*channels]==255 )
//                mask[i][j]=1;	   
//    
//    
//    Inpaint_P inp = initInpaint();
//    output_img = inpaint(inp, input_img, (int**)mask, 2);
//    if (!cvSaveImage(fileNameOutput,output_img))
    Inpaint_P inp = initInpaint();
    IplImage *outputImg = inpaint(inp, inputImage, (int**)mask, 2);
    UIImage *result = [UIImage fromIplImage:outputImg];
    
    for(int i = 0; i < size.height; ++i) {
        free(mask[i]);
    }
    
    cvReleaseImage(&inputImage);
    cvReleaseImage(&maskImage);
    cvReleaseImage(&outputImg);
    cvReleaseImage(&distorted);
    cvReleaseImage(&inputGray);
    cvReleaseImage(&distortedGray);
    
    return result;
}

- (IplImage *)iplImage {
    // Getting CGImage from UIImage
    CGImageRef imageRef = self.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(
                                       cvSize(self.size.width,self.size.height), IPL_DEPTH_8U, 4
                                       );
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
                                                    );
    // Drawing CGImage to CGContext
    CGContextDrawImage(
                       contextRef,
                       CGRectMake(0, 0, self.size.width, self.size.height),
                       imageRef
                       );
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2RGB);
    cvReleaseImage(&iplimage);
    
    return ret;
}

// NOTE You should convert color mode as RGB before passing to this function
+ (UIImage *)fromIplImage:(IplImage *)image {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}

@end

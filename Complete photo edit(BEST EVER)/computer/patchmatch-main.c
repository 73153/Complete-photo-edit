//
//  patchmatch-main.c
//  computer
//
//  Created by Nate Parrott on 5/10/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

#include "defineall.h"

double* G_globalSimilarity = NULL;
int G_initSim = 0;

double max1(double a, double b)
{
    return (a + b + fabs(a-b) ) / 2;
}

double min1(double a, double b)
{
    return (a + b - fabs(a-b) ) / 2;
}

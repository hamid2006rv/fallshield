#include <stdint.h>
#include <vector>
#include <iostream>
#include <opencv2/opencv.hpp>


extern "C" __attribute__((visibility("default"))) __attribute__((used))
int opticalflowEvent (int, int, uint8_t* , uint8_t* ,float32_t* ,uint32_t*);

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void getFeatures (int, int, uint8_t* ,float32_t* ,uint32_t* );

#include "falldetect.cpp"
#include "getFeatures.cpp"
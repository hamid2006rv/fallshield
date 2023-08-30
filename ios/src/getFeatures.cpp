#include <iostream>
#include <vector>
#include <stdint.h>
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

void getFeatures(int width, int height, uint8_t* frame_bytes , float32_t* buff , uint32_t*size)
{
     Mat frame(height, width, CV_8UC4, frame_bytes);
     vector<Point2f> p ;
     Mat gray;
     cvtColor(frame, gray, COLOR_BGR2GRAY);
     goodFeaturesToTrack(gray, p, 100, 0.3, 7, Mat(), 7, false, 0.04);

     std::vector<float> result;
     for(int i=0 ; i<p.size();i++)
     {
        result.push_back(p[i].x);
        result.push_back(p[i].y);
     }
     //for (float i: result)
         //std::cerr << i << ' ';
     memcpy( buff, result.data(),sizeof(float)*result.size());
     size[0] = result.size();

}
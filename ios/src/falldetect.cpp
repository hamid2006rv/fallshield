#include <iostream>
#include <vector>
#include <stdint.h>
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

int opticalflowEvent(int width, int height, uint8_t* old_frame_bytes,
                       uint8_t* frame_bytes,
                       float32_t* p0buff , uint32_t* size)
{

   // std::cerr << "befor" <<std::endl;

    vector<Point2f> p0;
     for(int i =0 ; i< size[0]/2; i++)
     {
       Point2f _p = Point2f(p0buff[2*i],p0buff[2*i+1]);
       p0.push_back(_p);
     }

    Mat frame(height, width, CV_8UC4, frame_bytes);
    Mat old_frame(height, width, CV_8UC4, old_frame_bytes);

    vector<Point2f> p1;

    Mat old_gray;
    cvtColor(old_frame, old_gray, COLOR_BGR2GRAY);
    Mat frame_gray;
    cvtColor(frame, frame_gray, COLOR_BGR2GRAY);

     vector<uchar> status;
     vector<float> err;
     TermCriteria criteria = TermCriteria((TermCriteria::COUNT) + (TermCriteria::EPS), 10, 0.03);
     try{
     calcOpticalFlowPyrLK(old_gray, frame_gray, p0, p1, status, err, Size(15,15), 2, criteria);
     }
     catch (const std::exception&) {
      std::cerr << "errorrr" << std::endl;
      return 0 ;
     }
    //std::cerr << p0.size() << ' ' << p1.size() <<std::endl;

    if(p1.size()==0){
       return 0 ;
    }
    else {
           vector<Point2f> good_new;
           for(uint i = 0; i < p0.size(); i++)
           {
               // Select good points
               if(status[i] == 1) {
               good_new.push_back(p1[i]);
           }

         std::vector<float> result;
         for(int i=0 ; i<good_new.size();i++)
         {
            result.push_back(good_new[i].x);
            result.push_back(good_new[i].y);
         }
         //for (float i: result)
             //std::cerr << i << ' ';
         memcpy( p0buff, result.data(),sizeof(float)*result.size());
         size[0] = result.size();
         //std::cerr << "p0 size " << result.size() << std::endl;
       }
    }
    //std::cerr << "okkkkk" << std::endl;
    return 1;
}
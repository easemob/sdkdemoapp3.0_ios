//
//  RedpacketDefines.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 2016/12/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#ifndef RedpacketDefines_h
#define RedpacketDefines_h

#define RedpacketImage(_imageName_) [UIImage imageNamed:[NSString stringWithFormat:@"RedpacketCellResource.bundle/%@", _imageName_]]


UIKIT_STATIC_INLINE UIColor * rpHexColor(uint color)
{
    float r = (color&0xFF0000) >> 16;
    float g = (color&0xFF00) >> 8;
    float b = (color&0xFF);
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}


#endif /* RedpacketDefines_h */

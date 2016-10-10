function [h,w,x,z] = getImageDims(b)
% GETIMAGEDIMS: Finds Image height, width, depth from first 24 bits
% Function Arguments: 
% b: Input:  24x1 double: Binary sequence of 1st 24 bits of 1st MSDU
% h: Output: 1x1  uint64: Scalar integer denotes height of image (#rows)
% w: Output: 1x1  uint64: Scalar integer denotes width  of image (#columns)
% x: Output: 1x1  uint64: Depth of image (1 for grayscale, 3 for color)
% z: Output: 1x1  uint64: Number of payload bits needed to Tx entire image
h = uint64(bi2de((b(01:11))'));
w = uint64(bi2de((b(12:22))'));
x = uint64(bi2de((b(23:24))'));
z = uint64(h*w*x*uint64(8)+uint64(24));
return;
end % END FUNCTION GETIMAGEDIMS
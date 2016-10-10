function bi_header_image_col = im2bi(image)
% Generate the image size bit vector
[h,w,c3] = size(image); 
header_h_w = de2bi([h,w],11)'; 
header_h_v_col = [header_h_w(:); de2bi(c3,2)'];

% Generate the image body bit vector
if c3>1
    image = permute(image,[3,1,2]);
end
image = double(image(:)); 
bi_image = de2bi(image, 8); 
bi_image = bi_image';
bi_image_col = bi_image(:); 

% Concatenate the 2 vectors
bi_header_image_col = [header_h_v_col; bi_image_col]; 
return;
end
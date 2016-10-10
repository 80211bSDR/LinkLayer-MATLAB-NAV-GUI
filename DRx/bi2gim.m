function image = bi2gim(bin,nib)
% Get #rows and #columns in image header bits
r1 = bi2de(bin(1:11).');
r2 = bi2de(bin(12:22).');
% Preallocate memory for binary matrix, decimal vector, & image pixel matrix
binmtx = zeros(8,r1*r2);
decvec = zeros(r1*r2,1);
image = uint8(zeros(r1,r2,'uint8'));
% Calculate #pixels recovered in binary, and place into their indices
npixel = floor((nib-24)/8);
binmtx(1:8,1:npixel) = reshape(bin(25:(8*npixel+24)),8,npixel);
decvec(1:npixel) = bi2de(binmtx(1:8,1:npixel).');
image(1:npixel) = uint8(decvec(1:npixel));
return;
end % END FUNCTION BI2GIM

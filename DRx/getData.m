function [ dib, nib ] = getData( choice, l )
%getData Allows for selection and handling of a data
%   Used for selection of data stream to be transmitted via USRP

switch choice

	% Choice 1, random stream of binary of length l
	case 1
		dib = randi([0 1],l,1);
		nib=l;
	

	% Choice 2, binary stream from fixed .jpg
	case 2
	    % Load Image Data with any size -- MPDU preparation 
	    fn  = 'membrane_color_smaller.jpg';  % fn: File Name
	    ii  = imfinfo(fn);
	    dib = im2bi(rgb2gray(imread(fn)));
	    nib = uint32(ii.Width*ii.Height*8+24);

end

end



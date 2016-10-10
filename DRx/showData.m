function showData( choice, nib, rib)
%showData Displays received data stream
%   Depending on 'choice,' displays binary stream or received image

switch choice

	% Choice 1, random stream of binary of length l
	case 1
	%do nothing
    return

	% Choice 2, binary stream from fixed .jpg
	case 2
        %show first image
        if nib{1} > 0
        rid{1} = bi2gim(rib{1},nib{1});
        f1 = figure(102);
        imshow(rid{1});
        end
        
        if nib{2} > 0
        %show second image
        rid{2} = bi2gim(rib{2},nib{2});
        f2 = figure(103);
        imshow(rid{2});
        end
        
end

end


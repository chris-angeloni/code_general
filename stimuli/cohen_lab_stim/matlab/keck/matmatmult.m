%
%function [Y] = matmatmult(X,D)
%
%	FILENAME	: MAT MAT MULT
%	DESCRIPTION 	: Matrix multiplication used to compute 2nd order STRF
%			  Works only for matlab 5.1 or greater
%
%	X		: Input Matrix
%	LD		: Downsampling Factor For Spectral Axis
%
function [Y] = matmatmult(X,LD)

count=1;
for k=1:LD:size(X,1)

	Y(:,:,count)=X(k,:)'*X(k,:);
	count=count+1;

end


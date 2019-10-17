%function [Imageout] = idownsam(Imagein)
%
%	FILE NAME 	: idownsam
%	DESCRIPTION 	: Down Samples an Image by a factor of 2
%
%	Note		: Make sure image is prefiltered!!!
%
function [Imageout] = idownsam(Imagein)

%Down Sampling
N=length(Imagein)/2;
Imageout=zeros(N,N);
for i=1:N
	for j=1:N
		Imageout(i,j)=Imagein(i*2,j*2);
	end
end
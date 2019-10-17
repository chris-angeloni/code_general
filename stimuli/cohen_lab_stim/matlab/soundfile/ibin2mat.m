%function [I] = loadbin(filename)
%
%	FILE NAME 	: I bin2mat
%	DESCRIPTION 	: Loads a Binary Formated image and saves as 
%			  matlab format
%	filename	: Input File Name
%	N		: Image Size
%			  NxN
%	I		: Image Matrix of type int
%
function [I] = loadbin(filename)

%Opening file
q=setstr(39);
command=['fid=fopen(',q,filename,q,');'];
eval(command);

%Reading the Data
Ibin=fread(fid,'uchar');

%Finding the Size
N=sqrt(length(Ibin));
I=zeros(N,N);

%Converting to int
for i=1:N
	for j=1:N
		I(i,j)=str2num(sprintf('%d',Ibin(i+(j-1)*N)));
	end
end

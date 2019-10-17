%function [I] = loadbin(filename)
%
%	FILE NAME 	: load bin
%	DESCRIPTION 	: Loads a Binary Formated image and returns an IMAGE
% 			  MATRIX of int.
%	filename	: Dah ...!
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
%Ibin=fscanf(fid,'%c');
Ibin=fread(fid,'uchar');
%Finding the Size
N=sqrt(length(Ibin));
I=zeros(N,N);
size(I)

%Converting to int
for i=1:N
	for j=1:N
		I(i,j)=str2num(sprintf('%d',Ibin(i+(j-1)*N)));
	end
end
%for i=1:N
%	I(i,:)=Ibin((i-1)*N+1:i*N);
%end

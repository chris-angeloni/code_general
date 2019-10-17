%
%function [Y]=treshold(X,T)
%
%	FILE NAME 	: TRESHOLD
%	DESCRIPTION 	: Tresholds and Image Array
%			  
%	X		: Input Image
%	T		: Treshold
%
%RETURNED VALUES
%	Y		: Output Image
%
function [Y]=treshold(X,T)

%Tresholding
i1=find(X>T);
i2=find(X<=T);
Y=zeros(size(X));
Y(i1)=255*ones(size(i1));


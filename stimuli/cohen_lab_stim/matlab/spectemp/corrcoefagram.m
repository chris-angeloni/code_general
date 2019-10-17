%
%function [R]=corrcoefagram(header,M,L)
%
%       FILE NAME       : CORR COEF AGRAM
%       DESCRIPTION     : Computes the cross band coerrelation coefficient
%			  for the audiogram
%
%	header		: File name header
%	M		: Data block size
%	L		: Number of blocks to use (Default=inf)
%
%RETURNED VALUES
%
%	R		: Correlatoin Coefficient Matrix
%
function [R]=corrcoefagram(header,M,L)

%Input Arguments
if nargin<3
	L=inf;
end

%Finding Cross Band Correlatoin Coefficient Matrix
count=0;
[ste]=xtractagram(header,M*count+1,M*(count+1));
R=zeros(size(ste,1),size(ste,1));
while size(ste)~=[1 1] & count<L
	clc
	disp(['Evaluating Block Number: ' int2str(count+1)])
	[ste]=xtractagram(header,M*count+1,M*(count+1));
	if size(ste)~=[1 1]
		for k=1:size(ste,1)
			for l=1:k
				RR=corrcoef(ste(k,:),ste(l,:));
				if size(RR)==[2 2]
					R(k,l)=R(k,l)+RR(1,2);
				end;
			end
		end
		count=count+1;
	end
end
R=R/count;

%Since matrix is symetric copy second half
for k=1:size(R,1)
	for l=1:k-1
		R(l,k)=R(k,l);		
	end
end

%Fixing diagonal correlation - 3 point average
R(1,1)=R(1,2);
R(size(R,1),size(R,1))=R(size(R,1),size(R,1)-1);
for k=2:size(R,1)-1
	R(k,k)=(R(k-1,k)+R(k-1,k+1)+R(k,k+1))/3;
end

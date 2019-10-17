%
%function [L,L05,L01]=strfsvdboot(STRF,N)
%
%
%       FILE NAME       : STRF SVD BOOT
%       DESCRIPTION     : Performs bootstrap to determine significant STRF
%			  singular values
%
%	STRF		: Receptive Field Bootstrap Array (NXxNTx1xNB)
%	N		: Number of bootstraps
%
%RETURNED VALUES
%
%	L		: Bootstrap Noise Singular Values
%	L05		: p<0.05 confidence interval on L
%	L01		: p<0.01 confidence interval on L
%
function [L,L05,L01]=strfsvdboot(STRF,N)

%Bootstrapping SVD
NB=size(STRF,3);
for k=1:N 
	clc
	disp(['Bootstrap: ' int2str(k) ' of ' int2str(N) ' trials'])

	%Computing SVD
	LB=round(rand(1,NB)*(NB-1)+1);
	[U,S,V]=svd(sum(STRF(:,:,LB),3));
	L(k,:)=diag(S)';
end

%Determining p<0.05 and p<0.01 confidence interval
L05=mean(L)+std(L)*1.6;
L01=mean(L)+std(L)*2.34;


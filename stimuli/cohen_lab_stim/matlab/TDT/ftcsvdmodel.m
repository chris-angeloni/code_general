%
% function [FTCm,U,S,V] = ftcsvdmodel(FTC,N)
%
%	FILE NAME 	: FTC SVD MODEL
%	DESCRIPTION : Singular Value Decomposition model of frequency tunning curve
%
%	FTC	        : Tunning Curve Data Structure
%                   FTC.Freq                - Frequency Axis
%                   FTC.Level               - Sound Level Axis (dB)
%                   FTC.data                - Data matrix
%   N           : Number of singular values for model
%
% RETURNED DATA
%
%	FTCm        : Model Tunning Curve Data Structure
%                   FTCm.Freq                - Frequency Axis
%                   FTCm.Level               - Sound Level Axis (dB)
%                   FTCm.data                - Data matrix
%   S, V, D     : Singular Value Decomposition Matrices
%   SS          : Nth order rank singular value matrix
%
function [FTCm,U,S,V,SS] = ftcsvdmodel(FTC,N)

%Singular Value Decomposition
[U,S,V]=svd(FTC.data);

%Selecting N Singular Values
SS=zeros(size(S));
for k=1:N
    SS(k,k)=S(k,k);    
end

%Model FTC
FTCm=FTC;
FTCm.data=U*SS*V';
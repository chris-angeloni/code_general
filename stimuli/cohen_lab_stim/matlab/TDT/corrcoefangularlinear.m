%
%function [Rb]=corrcoefangularlinear(X,Y,NB)
%
%
%       FILE NAME       : CORR COEF ANGULAR LINEAR
%       DESCRIPTION     : Angular-Linear correlation coefficient. Assumes
%                         X is an angular variable and Y is a linear variable. Returns
%                         bootstraped resamples for the angular-linear
%                         correlation coefficient.
%
%                         Uses Eqn. 27.47 on pg. 651 from Zar. 
%
%       X               : Linear variable (range is arbitrary)
%       Y               : Angular variable (0-2*pi)
%       NB              : Number of bootstraps
%
%Returned Variables
%       Rb              : Bootstrap values for angular-linear correlation
%                         coefficient
%
% (C) Monty A. Escabi, Jan 2006
%
function [Rb]=corrcoefangularlinear(X,Y,NB)

%Degrees of freedom in data
N=length(X);

%Computing Circular correlation
for k=1:NB
    
    %Bootstrap Samples
    [Xb,Yb]=bootrsp2(X,Y,NB);
    Cb=cos(Yb);
    Sb=sin(Yb);
    
    %Transformed Correlations
    rxc=corrcoef(Xb,Cb);
    rxc=rxc(1,2);
    rxs=corrcoef(Xb,Sb);
    rxs=rxs(1,2);
    rcs=corrcoef(Cb,Sb);
    rcs=rcs(1,2);
    
    %Computing Angular-Linear Correlation Coefficient
    Rb(k)=sqrt(rxc^2+rxs^2-2*rxc*rxs*rcs)/sqrt(1-rcs^2);
    
end
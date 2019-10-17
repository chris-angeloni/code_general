%
%function [Rb]=corrcoefangular(X,Y,NB)
%
%
%       FILE NAME       : CORR COEF ANGULAR
%       DESCRIPTION     : Circular/angular correlation coefficient. Assumes
%                         X and Y are angular variables. Returns
%                         bootstraped resamples for the circular
%                         correlation coefficient.
%
%                         Uses Eqn. 27.43 on pg. 649 from Zar. 
%
%       X               : Angular variable 1 (0-2*pi)
%       Y               : Angular variable 2 (0-2*pi)
%       NB              : Number of bootstraps
%
%Returned Variables
%       Rb              : Bootstrap values for angular correlation
%                         coefficient
%
% (C) Monty A. Escabi, Jan 2006
%
function [Rb]=corrcoefangular(X,Y,NB)

%Degrees of freedom in data
N=length(X);

%Computing Circular correlation
for k=1:NB
    
    %Initializing Terms for correlation
    Sxy=0;
    Sx=0;
    Sy=0;
    
    %Bootstrap Samples
    [Xb,Yb]=bootrsp2(X,Y,NB);
    
    %Computing Correlation
    for i=1:N-1
        for j=i+1:N
           
            Sxy=Sxy+sin(Xb(i)-Xb(j))*sin(Yb(i)-Yb(j));
            Sx=Sx+sin(Xb(i)-Xb(j))^2;
            Sy=Sy+sin(Yb(i)-Yb(j))^2;
            
        end
    end
    
    Rb(k)=Sxy/sqrt(Sx*Sy);
    
end

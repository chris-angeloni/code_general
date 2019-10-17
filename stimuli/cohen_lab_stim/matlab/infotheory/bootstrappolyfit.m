%
%function [P]=bootstrap(X,Y,N)
%
%
%       FILE NAME       : BOOT STRAP POLYFIT
%       DESCRIPTION     : Bootstrap algorithm for polyfit
%
%       X		: Input Data
%	Y		: Output Data
%	N		: Number of bootstraps
%
%Returned Variables
%	P		: Bootstrapped Polyfit Data Matrix 
%
function [P]=bootstrap(X,Y,N)

%Converting to Imaginary Number
Data=[X+i*Y];


%Resampling and Bootstrapping
for k=1:N
        out=bootrsp(Data,length(Data));
        Xb=real(out);
        Yb=imag(out);
        P(k,:)=polyfit(Xb,Yb,1);
end



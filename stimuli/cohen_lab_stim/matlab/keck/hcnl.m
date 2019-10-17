%
%function [y]=hcnl(x,ymax,ymin,xo,alpha)
%
%
%   FILE NAME   : HCNL
%   DESCRIPTION : Hair Cell NonLinearity
%
%   x           : Input
%   ymax        : Maximum output level
%   ymin        : Minimum output level
%   xo          : Operating point (>0)
%   alpha       : Smoothing/Slope parameter
%   y           : Output
%
function [y]=hcnl(x,ymax,ymin,xo,alpha)

%y=(ymax-ymin)./(1+exp(-alpha.*(x-xo)))+ymin;
%Rectifying Nonlinearity
y=x;
index=find(x<=0);
y(index)=zeros(size(index));
a=1;
index=find(x>10^(-a));
y(index)=a+log10(x(index));
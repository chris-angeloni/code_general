% function STRFtempo=tempofit(beta,x);
%
% Function         it is for strfmodel_ic.m
%
% Copyright ANQI QIU
% 07/01/2001
% Modified by Monty A. Escabi
% 04/8/03

function STRFtempo=tempofit(beta,x);

%t=x-((x-beta(1))*beta(6)).^2/2-beta(1);
t=2*atan(beta(6)*x)-beta(1);

STRFtempo=beta(5)*exp(-(2*t/beta(2)).^2).*cos(2*pi*beta(3)*t+beta(4));
%STRFtempo=beta(5)*exp(-(2*(2*sqrt(beta(6)*x)-beta(1))/beta(2)).^2).*cos(2*pi*beta(3)*(2*sqrt(beta(6)*x)-beta(1))+beta(4));   


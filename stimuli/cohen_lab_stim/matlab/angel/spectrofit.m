%function STRFspetro=spectrofit(beta,x); 
%
%Function       it is for strfmodel_ic.m


function STRFspetro=spectrofit(beta,x);

%x0=beta(1);
%w=beta(2);
%sf=beta(3);
%p=beta(4);
%k=beta(5);
STRFspetro=beta(5)*exp(-(2*(x-beta(1))/beta(2)).^2).*cos(2*pi*beta(3)*(x-beta(1))+beta(4));

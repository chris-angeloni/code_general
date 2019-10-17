% function [beta,Y]=srfmodel(X,Y0,BestRD);
%
% Description: fitting spectral profile (SRF)
%
% Input:
%           X           frequency axis (log2(faxis/500))
%           Y0          measured spectral profile
%           BestRD      the best ripple density for the SRF
% Output 
%           beta        parameters in Gabor function
%                       beta(1)  center frequency
%                       beta(2)  bandwidth of the SRF
%                       beta(3)  the best ripple density
%                       beta(4)  spectral phase
%                       beta(5)  peak value
%           Y           fitted SRF
%
%  ANQI QIU
%  05/03/2002
%


function [beta,Y]=srfmodel(X,Y0,BestRD);

if nargin<3
    BestRD=0;
end;

%the envelope of Y
EY=abs(hilbert(Y0));

%to assign initial paramters
%the peak point of EY
beta0(1)=X(find(EY==max(EY)));
%the bandwidth of EY
beta0(2)=X(max(find(EY>=max(EY)*exp(-1))))-X(min(find(EY>=max(EY)*exp(-1))));
%modulation frequency (temporal or spectral)
beta0(3)=BestRD;
%phase
beta0(4)=2*pi*beta0(3)*(beta0(1)-X(find(abs(Y0)==max(abs(Y0)))));
%peak amplitude
beta0(5)=max(abs(Y0));

%to fit Y0
warning off;
try
    beta=lsqcurvefit('spectrofit',beta0,X,Y0');
    Yt=beta0(5)*exp(-(2*(X-beta0(1))/beta0(2)).^2).*cos(2*pi*beta0(3)*(X-beta0(1))+beta0(4));
    Y=beta(5)*exp(-(2*(X-beta(1))/beta(2)).^2).*cos(2*pi*beta(3)*(X-beta(1))+beta(4));   
    %comparison between fitted result and initial result
    if (sum((Y-Y0').^2)>sum((Yt-Y0').^2)) & (sum(Y==0)~=length(Y)) 
        beta=beta0;
    else if sum(Y==0)==length(Y)
            disp('Warning! Spectral profile is zero');
            Y=zeros(size(Y0));
            beta=zeros(size(beta));
         end
    end      
catch
    disp('Keep initial parameters');
    beta=beta0;
end;

%to motify the range of parameters
if beta(5)<0
    beta(4)=beta(4)+pi;
    beta(5)=-beta(5);
end
if beta(3)<0
    beta(3)=-beta(3);
    beta(4)=-beta(4);
end
if beta(4)>2*pi
    beta(4)=beta(4)-2*pi*round(beta(4)/2/pi);
else if beta(4)<-2*pi
        beta(4)=beta(4)-2*pi*(round(beta(4)/2/pi)-1);
     end;
end;

if beta(4)>pi
    beta(4)=beta(4)-2*pi;
else if beta(4)<-pi
        beta(4)=beta(4)+2*pi;
     end;
end;

if sum(Y==0)~=length(Y)
	Y=beta(5)*exp(-(2*(X-beta(1))/beta(2)).^2).*cos(2*pi*beta(3)*(X-beta(1))+beta(4));
end








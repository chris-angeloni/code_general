% function [beta,Y]=trfmodel(X,Y0,BestFm);
%
% Description:   
%                fitting a temporal profile (TRF)
%
% Input: 
%              X           time axis 
%              Y0          measured temporal profile
%              BestFm      the best temporal modulation frequency
% Output:
%              beta        parameters in Gabor function
%                          beta(1)     peak latency
%                          beta(2)     response duration
%                          beta(3)     the best temporal modulation frequency
%                          beta(4)     temporal phase
%                          beta(5)     peak value
%                          beta(6)     skewing coefficient
%              Y           fitted TRF
%
% ANQI QIU
% 05/03/2002
%


function [beta,Y]=trfmodel(X,Y0,BestFm);

if nargin<3
    BestFm=0;
end;

X=X+abs(X(1));

%the envelope of Y
EY=abs(hilbert(Y0));

%to assign initial paramters
%the peak point of EY
beta0(1)=X(find(EY==max(EY)));
%the bandwidth of EY
beta0(2)=X(max(find(EY>=max(EY)*exp(-1))))-X(min(find(EY>=max(EY)*exp(-1))));
%modulation frequency (temporal or spectral)
beta0(3)=BestFm;
%phase
beta0(4)=2*pi*beta0(3)*(beta0(1)-X(find(abs(Y0)==max(abs(Y0)))));
%peak amplitude
beta0(5)=max(abs(Y0));
beta0(6)=tan(0.5*X(find(abs(Y0)==max(abs(Y0)))))/X(find(abs(Y0)==max(abs(Y0))));
%to fit Y0
warning off;
try
    beta=lsqcurvefit('tempofit',beta0,X,Y0);
    Yt=beta0(5)*(exp(-(2*(2*atan(beta0(6)*X)-beta0(1))/beta0(2)).^2).*cos(2*pi*beta0(3)*(2*atan(beta0(6)*X)-beta0(1))+beta0(4)));
    Y=beta(5)*(exp(-(2*(2*atan(beta(6)*X)-beta(1))/beta(2)).^2).*cos(2*pi*beta(3)*(2*atan(beta(6)*X)-beta(1))+beta(4)));
    %comparison between fitted result and initial result
    if (sum((Y-Y0).^2)>sum((Yt-Y0).^2)) & (sum(Y==0)~=length(Y))
        Y=Yt;
        beta=beta0;
    else if sum(Y==0)==length(Y)
            disp('Warning! Temporal profile is zero');
            Y=zeros(size(Y0));
            beta=zeros(size(beta));
         end            
    end      
catch
    disp('Keep initial parameters');
    Y=beta0(5)*(exp(-(2*(2*atan(beta0(6)*X)-beta0(1))/beta0(2)).^2).*cos(2*pi*beta0(3)*(2*atan(beta0(6)*X)-beta0(1))+beta0(4))); 
    beta=beta0;
end;

%to motify the range of parameters
if beta(5)<0
    beta(4)=beta(4)+pi;
    beta(5)=-beta(5);
end
%if beta(3)<0
%    beta(3)=-beta(3);
%    beta(4)=-beta(4);
%end
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
	Y=beta(5)*(exp(-(2*(2*atan(beta(6)*X)-beta(1))/beta(2)).^2).*cos(2*pi*beta(3)*(2*atan(beta(6)*X)-beta(1))+beta(4))); 
end;






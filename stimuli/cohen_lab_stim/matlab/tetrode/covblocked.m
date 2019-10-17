%
%function [C]=covblocked(X,US,ND,L)
%
%   FILE NAME   : COV BLOCKED INT
%   DESCRIPTION : Covariance matrix for long data streams. Computed in
%                 data blocks of L samples. Data is interpolated by factor
%                 US. Used for tetrode analysis.
%
%   X           : NxM Data matrix where N is the number of independent
%                 observations and M is the number of variables
%   US          : Upsampling factor
%   ND          : Number of derivatives
%   L           : Data block size for computing covariance
%        
%RETURNED PARAMETERS
%
%   C           : Covariance Matrix (MxM)
%
% (C) M.A. Escabi, July 2008
%
function [C]=covblocked(X,US,ND,L)

%Definitions
N=size(X,1);
M=size(X,2);
C=zeros(M,M);
MC=0;           %Number of samples used for covariance estimate

%Computing Covariance
for k=1:floor(N/L)+1
    
        %Display Output
        clc
        disp(['Computing Covariance Matrix: ' int2str(100*k/(floor(N/L)+1)) ' % Done'])
        
        %Interpolating Waveform Blocks
        if k<floor(N/L)+1
            Xt=X((k-1)*L+1:k*L,:)';
        else
            Xt=X((k-1)*L+1:length(X),:)';       %Last Block
        end
        
        if length(Xt)>1
            MM=size(Xt,2);
            for l=1:M
                Xtemp(l,:)=interp1(1:MM,Xt(l,:),1:1/US:MM,'spline');
            end
            clear Xt
        
            %Covariance of Raw Waveform
            if ND>0
                Xtemp=diff(Xtemp,ND,2);
            end
            MX=length(Xtemp);
            Ctemp=cov(Xtemp');
            C=C+Ctemp*(MX-1);
            clear Xtemp
        
            %Number of Samples used for covariance estimate
            MC=MC+MX;
        end
end

%Normalizing
C=C/(MC-1);
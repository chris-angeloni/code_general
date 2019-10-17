%
%function [R]=rastercircularxcorrfast(RASTER1,RASTER2,Fsd,Delay,NJ)
%
%   FILE NAME       : RASTER CIRCULAR X CORR FAST
%   DESCRIPTION     : Cross rastergram circular correlation function.
%                     The standard error is obtaine with a Jackknife on the
%                     original data samples.
%
%	RASTER2         : Cycle Rastergram (compressed spet format). Generated
%                     using RASTER2CYCLERASTER
%	RASTER1         : Cycle Rastergram (compressed spet format). Generated
%                     using RASTER2CYCLERASTER
%   Fsd             : sampling rate of raster to compute raster-corr.
%   Delay           : Rearranges the shuffled correlation so that the
%                     zeroth bin is centered about the center of the
%                     correaltion function (at the floor(N/2)+1 sample).
%                     Otherwize, the zeroth bin of the correaltion function
%                     is located at the first sample of Rshuf. (OPTIONAL,
%                     Default == 'n')
%	NJ              : Number of Jackknives for Cross Correlation Estimate
%                     (Default = 0). This is used to compute the standard
%                     errror on all statistics.
%RETURNED VALUES
%
%   R               : Data structure containing:
%                     .Rshuf    - Shuffled correlation fuction
%                     .Rset     - Shuffled correlation standard error
%                                 across trials
%                     .RshufJt  - Jackknife matrix containing shuffled 
%                                 correlation functions for NJ Jackknives
%                                 (across trials).
%                     .Rsec     - Shuffled correlation standard error
%                                 across correlations
%                     .RshufJc  - Jackknife matrix containing shuffled 
%                                 correlation functions for NJ Jackknives
%                                 (across correlations).
%
% (C) Monty A. Escabi, July 2007
%
function [R]=rastercircularxcorrfast(RASTER1,RASTER2,Fsd,Delay,NJ)

%Input Args
if nargin<3
   Delay='n'; 
end
if nargin<4
    NJ=0;
end

%Expand rastergram into matrix format
T=RASTER1(1).T
[RAS1,Fs]=rasterexpand(RASTER1,Fsd,T);
[RAS2,Fs]=rasterexpand(RASTER2,Fsd,T);

%Rastergram Length
L=size(RAS1,2);
M=size(RAS1,1);
    
%Computing Cross Circular Correlation
F1=fft(RAS1,[],2);
F2=fft(RAS2,[],2);
R=mean(real(ifft(F1.*conj(F2),[],2)/Fsd/T));

%PSTH=sum(RAS,1);
%F=fft(PSTH);
%R=real(ifft(F.*conj(F)))/Fsd/T;
%F=fft(RAS,[],2);
%Rdiag=real(ifft(F.*conj(F),[],2)/Fsd/T);
%Rshuf=(R-sum(Rdiag)) / (M*(M-1));

%Shifting zeroth bin
if Delay=='y'
   R=fftshift(R); 
end

% %Performing a Jackknife if desired
% if NJ>=1
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %JACKKNIFING DATA ACROSS TRIALS
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %Permuting Trials
%     NJt=min(M,NJ);   %Make sure we have enough trials
%     index=randperm(M);
%     RAS=RAS(index,:);
% 
%     %Correlation For Diagonals
%     F=fft(RAS,[],2);
%     Rdiag=real(ifft(F.*conj(F),[],2)/Fsd/T);
% 
%     %Jackknifing data across rastergram trials
%     for k=1:NJt        
%         %Computing Correlation Functions
%         i=[index(1:k-1) index(k+1:M)];      %Jackknife subsample
%         PSTH=sum(RAS(i,:),1);
%         F=fft(PSTH);
%         R=real(ifft(F.*conj(F)))/Fsd/T;
% 
%         %F=fft(RAS(i,:),[],2);
%         %Rdiag=real(ifft(F.*conj(F),[],2)/Fsd/T);
% 
%         RshufJt(k,:)=(R-sum(Rdiag(i,:))) / ((M-1)*(M-2));
%     end
%     if Delay=='y'
%         RshufJ=fftshift(RshufJt);
%     end
% 
%     %Computing Jacknife Residuals
%     for k=1:NJt        
%         Rrest(k,:)=mean(RshufJt,1)-RshufJt(k,:);
%     end
% 
%     %Standard Error (across trials) on Shuffled Corr
%     Rset=sqrt((M-1)*var(Rrest));
% 
% 
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %JACKKNIFING DATA ACROSS CORRELATIONS
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %Finding Sample Indeces
% %     NJc=min(M*(M-1),NJ);    %Make sure we have enough correlations
% %     index=randsample(M,2)';
% %     while length(index)<NJc     %Fast implementation - previously generated all possibilities, way too slow
% %         i=randsample(M,2)';     %Samples without replacement
% %         if sum(index(:,1)~=i(1) & index(:,2)~=i(2)) %Without Replacement
% %             index=[index; i];
% %         end
% %     end
% % 
% %     %Computing Correlation for each jackknife correlation to remove
% %     F1=fft(RAS(index(:,1),:),[],2);
% %     F2=fft(RAS(index(:,2),:),[],2);
% %     Rc=real(ifft(F1.*conj(F2),[],2))/Fsd/T;
% %     if Delay=='y'
% %         Rc=fftshift(Rc); 
% %     end
% %     %Computing Jacknife Samples
% %     for k=1:NJc
% %         RshufJc(k,:)=( Rshuf*M*(M-1)-Rc(k,:) ) / ( M*(M-1) - 1 );
% %     end 
% %     
% %     %Computing Jacknife Residuals
% %     for k=1:NJc
% %         Rresc(k,:)=mean(RshufJc,1)-RshufJc(k,:);
% %     end
% %     
% %     %Standard Error (across correlations) on Shuffled Corr
% %     Rsec=sqrt((M*(M-1)-1)*var(Rresc));
% 
% else
%    RshufJt=-9999;
%    Rset=-9999;
%    RshufJc=-9999;
%    Rsec=-9999;   
% end

%Converting to data structure
R.R=R;
%R.RshufJt=RshufJt;
%R.Rset=Rset;
R.lambda1 = mean(mean(RAS1));  % average firing rate
R.lambda2 = mean(mean(RAS2));  % average firing rate

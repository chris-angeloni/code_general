%
%function [eig1,eig2,Tresh]=rstrfstateigen(sprfile,Wo,times,Fs,UF,MaxT,Sound,NB,p)
%
% Function         to estimate level of noise dependent on spike rate
%
% Input:         
%          sprfile      SPR Filename
%	   Wo           the array of spike rate
%          times        the number of running times for each spike rate
%          Fs	        sampling rate for SPR file (e.g. ICC experiments 44100/44)
%	   UF 		temporal upsampling factor for STRF (e.g. ICC experiment UF=4)
%	   MaxT         Maximum delay for computing STRF (Default==0.1 sec)
%          Sound        stimulus type: 'MR' or 'RN'
%		        (Default=='MR')
%	   NB           number of stimulus blocks
%		        (Default==1706 for MR / Default==1500 for RN)
%	   p		Significance level for threshold (Default==0.01)
%
% Output:
%          eig1     the matrix of level of noise for controlateral STRF
%          eig2     the matrix of level of noise for ipsilateral STRF
%	   Tresh    Significance threshold to achieve p confidence interval
%
% Angel  05/01/2002
% Escabi 03/19/2003
%
function [eig1,eig2,Tresh]=rstrfstateigen(sprfile,Wo,times,Fs,UF,MaxT,Sound,NB,p)

%Input Arguments
if nargin<6
	MaxT=0.1;
end
if nargin<7
	Sound='MR';
end
if nargin<8
	if strcmp(Sound,'MR')
		NB=1706;
	else
		NB=1500;
	end 
end
if nargin<9
	p=0.01;
end

%initial parameters
Fsd=24000;  

%for dynamic ripples
k=1:NB;

%to generate Trigger signal
L=ceil(32000/44100*Fs);    	%Number of temporal samples for each 3/4 sec SPR block
				% For ICC experiments typically L=728
Trig=round(((k-1)*L+1)/Fs*Fsd);   

for n=1:length(Wo),
   for m=1:times,
      %to generate random spikes 
      spetr=poissongen(Wo(n)*ones(1,1200),1,Fsd); 
      [taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrfdbint(sprfile,0,MaxT,spetr,Trig,Fsd,60,30,'dB',Sound,100,UF,'float');
      try
   		[U,S,V]=svd(STRF1*sqrt(PP));
      end
      eig1(m,n)=S(1,1);
      try
                [U,S,V]=svd(STRF2*sqrt(PP));
      end
      eig2(m,n)=S(1,1); 
   end;
end

%Computing the Significance Treshhold
eig=[eig1;eig2];
N=sqrt(2)*erfinv(1-p);
Tresh=mean(eig)+N*std(eig);

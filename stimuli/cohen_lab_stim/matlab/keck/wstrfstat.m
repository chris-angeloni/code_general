%
%function [STRF,Tresh]=wstrfstat(STRF,p,No,Wo,PP,MdB,ModType,Sound,SModType)
%
%       FILE NAME       : WSTRF STAT
%       DESCRIPTION     : Performs a significance test and determines
%			  The statistically significant portion STRF
%
%	STRF		: Spectro-Temporal Receptive Field
%	p		: Significance Probability
%	No		: Number of Spikes
%	Wo		: Zeroth Order Kernel ( Number of Spikes / Sec )
%	PP		: Power Level
%	MdB		: Modulation depth
%	ModType		: Modulation type used to construct Receptive Field 
%	Sound		: Sound Type
%			  Moving Ripple : 'MR' ( Default )
%			  Ripple Noise  : 'RN'
%	SModType	: Sound Modulation Type : 'lin' or 'dB'
%
%RETURNED VALUES
%	STRF		: Significant STRF for a significance prob. of p
%	Tresh		: Treshold value for a significance prob. of p
%
function [STRF,Tresh]=wstrfstat(STRF,p,No,Wo,PP,MdB,ModType,Sound,SModType)

if strcmp(SModType,'dB')
	if strcmp(ModType,'dB')
		if strcmp(Sound,'RN')
			sigma=sqrt(No)*MdB/sqrt(12);		%Uniform Amplitude Distribution
		elseif strcmp(Sound,'MR')
			sigma=sqrt(No)*MdB/sqrt(8);		%Sinusoid Amplitude Distribution
		end
		sigma=Wo/PP*sigma/No;
	else
		if strcmp(Sound,'RN')
			sigma=sqrt(No*PP);			%Recall that STD was Normalized to sqrt(PP)
			sigma=Wo/PP*sigma/No;
		elseif strcmp(Sound,'MR')
			sigma=sqrt(No*PP);			%Recall that STD was Normalized to sqrt(PP)
			sigma=Wo/PP*sigma/No;
		end
	end
else
	if strcmp(ModType,'dB')
		if strcmp(Sound,'RN')
			X=rand(1,1024*16);
			epsilon=10^(-MdB/20);
			Z=20*log10((1-epsilon)*X+epsilon);
			RMSP=mean(Z);					% RMS value of normalized Spectral Profile
			PP=var(Z);					% Modulation Depth Variance
			sigma=sqrt(No*PP);
			sigma=Wo/PP*sigma/No;
 		elseif strcmp(Sound,'MR')
			X=rand(1,1024*16)*2*pi;
			epsilon=10^(-MdB/20);
			Z=20*log10(.5*(1-epsilon)*(sin(X)+1)+epsilon);
			RMSP=mean(Z);					% RMS value of normalized Spectral Profile
			PP=var(Z);					% Modulation Depth Variance
			sigma=sqrt(No*PP);
			sigma=Wo/PP*sigma/No;
      		end 
	else
		if strcmp(Sound,'RN')
			sigma=sqrt(No*PP);			%Recall that STD was Normalized to sqrt(PP)
			sigma=Wo/PP*sigma/No;
		elseif strcmp(Sound,'MR')
			sigma=sqrt(No*PP);			%Recall that STD was Normalized to sqrt(PP)
			sigma=Wo/PP*sigma/No;
		end

	end
end

%Finding the STD Threshold required to exceed a Right Tail 
%Probability of p
Tresh=sqrt(2)*erfinv(1-2*p);

%Finding Non Significant STRF
[i,j]=find(abs(STRF)<Tresh*sigma);

%Setting Non-Significant STRF == 0
for k=1:length(i)
	STRF(i(k),j(k))=0;
end

%Treshold value for the choosen significance prob.
Tresh=Tresh*sigma;

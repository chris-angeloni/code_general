%
%function [C,X]=ncscoherethetagamma(Data,chan1,chan2,f1t,f2t,TWt,f1g,f2g,TWg,df,Disp)
%
%DESCRIPTION: Theta-Gamma coherence for multi channel data from NCS file
%
%   Data	: Data structure containg all NCS channels from single 
%             recording session (obtained using READALLNCS)
%   chan1	: Array of reference THETA channels to correlate
%   chan2 	: Array of secondary GAMMA channesl to correlate
%   f1t,f2t : Lower and upper filter cutoff for theta band (Hz)
%   TWt     : Transition width for theta band (Hz)
%   f1g,f2g : Lower and upper filter cutoff for gamma band (Hz)
%   TWg     : Transition width for gamma band (Hz)
%   df		: Spectral Resolution in Hz
%   Disp    : Display Results: 'y' or 'n' (Default=='n')
%
%RETURNED VARIABLES
%
%   C       : Theta-Gamma Coherence Data Structure for all Channels
%   X       : Data structure containing theta and gamma signals
%             .Xt   - Theta signal
%             .Xg   - Gamma signal
%             .Envg - Gamma Envelope
%
%Monty A. Escabi, July 1, 2007 (Edit Oct 2007)
%
function  [C,X]=ncscoherethetagamma(Data,chan1,chan2,f1t,f2t,TWt,f1g,f2g,TWg,df,Disp)

%Input Arguments
if nargin<11
    Disp='n';
end

%Choosing Window Function 
Fs=Data(1).Fs;
ATT=40;
W=designw(df,40,Fs);
NFFT=2^nextpow2(length(W));

%Quantized Amplitude Scaling Factor
dA=Data(1).ADBitVolts;

%Computing Coherence
for k=1:length(chan1)       %Index for theta
	for l=1:length(chan2)   %Index for gamma

        %Filtering Theta and Gamma Band Signals
        Ht=bandpass(f1t,f2t,TWt,Fs,ATT,'n');
        Hg=bandpass(f1g,f2g,TWg,Fs,ATT,'n');
        Xt=conv(dA*Data(chan1(k)).X,Ht);
        Xg=conv(dA*Data(chan2(l)).X,Hg);

        %Truncating Initial Segments to Remove Edge Artifact
        Nt=(length(Ht)-1)/2;
        Ng=(length(Hg)-1)/2;
        if Nt>=Ng
            
            Xt=Xt(Nt+1:length(Xt)-Nt);  %Makes length == X
            Xg=Xg(Ng+1:length(Xg)-Ng);  %Makes length == X
            
            Xt=Xt(Nt+1:length(Xt)-Nt);
            Xg=Xg(Nt+1:length(Xg)-Nt);
 
        else
            
            Xt=Xt(Nt+1:length(Xt)-Nt);  %Makes length == X
            Xg=Xg(Ng+1:length(Xg)-Ng);  %Makes length == X
            
            Xt=Xt(Ng+1:length(Xt)-Ng);
            Xg=Xg(Ng+1:length(Xg)-Ng);
            
        end
        
        %Extracting Gamma Band Envelope
        Hilg=hilbert(Xg);
        Envg=abs(Hilg);
        
		%Coherence Estimate
		[C(k,l).Cxy,C(k,l).Faxis]=...
			cohere(Xt,Envg,NFFT,Fs,W);
		C(k,l).ADChannels=...
			[Data(chan1(k)).ADChannel Data(chan2(l)).ADChannel];

        %Converting Coherence from Coherence^2
        C(k,l).Cxy=sqrt(C(k,l).Cxy);                %Monty Escabi, Dec 27 2006
        
        %Plotting Results If Desired
        if Disp=='y'
      
            subplot(211)
            hold off
            [Pxxt,Faxis]=pwelch(Xt,W,[],NFFT,Fs);
            [Pxxg,Faxis]=pwelch(Xg,W,[],NFFT,Fs);
            plot(Faxis,10*log10(Pxxt),'b')
            hold on
            plot(Faxis,10*log10(Pxxg),'r')
            i=find(Faxis<f2g*4);
            Max=10*log10(max([Pxxt(i)' Pxxg(i)']))+10;
            Min=min( 10*log10([Pxxt(i)' Pxxg(i)']))-10 ;
            axis([0 max(Faxis(i)) Min Max])
            
            subplot(212)
            plot(C(k,l).Faxis,C(k,l).Cxy,'r'),axis([0 25 0 1]) 
        
            pause(0)
            
        end
        
	end
end

%Adding Signals to Data Structure
X.Xt=Xt;
X.Xg=Xg;
X.Envg=Envg;
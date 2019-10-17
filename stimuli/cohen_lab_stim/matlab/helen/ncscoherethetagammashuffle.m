%
%function  [Cs]=ncscoherethetagammashuffle(Data,chan1,chan2,f1t,f2t,TWt,f1g,f2g,TWg,df,N,flag)
%
%DESCRIPTION: Theta-Gamma shuffled Coherences for multi channel data from NCS file
%
%   Data        : Data structure containg all NCS channels from single 
%                 recording session (obtained using READALLNCS)
%   chan1       : Array of reference channels to correlate
%   chan2       : Array of secondary channesl to correlate
%   f1t,f2t     : Lower and upper filter cutoff for theta band (Hz)
%   TWt         : Transition width for theta band (Hz)
%   f1g,f2g     : Lower and upper filter cutoff for gamma band (Hz)
%   TWg          : Transition width for gamma band (Hz)
%   df          : Spectral Resolution in Hz
%   N           : Number of shuffling itterations (Default==250)
%   flag        : Significance criterion
%                 1: Fixed Threshold (Default)
%                 2: Frequency Dependent Threshold
%
%RETURNED VARIABLES
%
%   Cs          : Shuffled Coherence Data Structure (For significance Analysis)
%   C01         : 0.01 confidence interval
%	C05         : 0.05 confidence interval
%   ADChannels	: Channels used for coherence estimates
%	Faxis		: Frequency Axis
%
%Monty A. Escabi, March 29, 2006
%
function [Cs]=ncscoherethetagammashuffle(Data,chan1,chan2,f1t,f2t,TWt,f1g,f2g,TWg,df,N,flag)

%Input Arguments
if nargin<5
   N=250; 
end
if nargin<6
	flag=1;
end

%Choosing Window Function 
Fs=Data(1).Fs;
ATT=40;
W=designw(df,40,Fs);
NFFT=2^nextpow2(length(W));

%Quantized Amplitude Scaling Factor
dA=Data(1).ADBitVolts;

%Flag - Used to minimize the number of coherence calculations
Max=max([chan1 chan2]);
FLAG=zeros(Max,Max);

%Computing Coherence
for k=1:length(chan1)
	for l=1:length(chan2)

        if FLAG(chan2(l),chan1(k))
            %Copying Coherence Data
            index2=find(chan1(k)==chan2);
            index1=find(chan2(l)==chan1);
            Cs(k,l)=Cs(index1,index2);
            
            %Setting Flag
            FLAG(chan1(k),chan2(l))=1;
        else
            %Shuffling
            for n=1:N
                
            	%Shuffled Coherence Estimate
            	X1=randphasespec(Data(chan1(k)).X);
                X2=randphasespec(Data(chan2(l)).X);
                
                %Filtering Theta and Gamma Band Signals
                Ht=bandpass(f1t,f2t,TWt,Fs,ATT,'n');
                Hg=bandpass(f1g,f2g,TWg,Fs,ATT,'n');
                Xt=conv(dA*X1,Ht);
                Xg=conv(dA*X2,Hg);

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
            	[CS(n).Cxy,Cs(k,l).Faxis]=...
            		cohere(Xt,Envg,NFFT,Fs,W);
            	Cs(k,l).ADChannels=...
            		[Data(chan1(k)).ADChannel Data(chan2(l)).ADChannel];        
                
                %Converting Coherence from Coherence^2
                CS(n).Cxy=sqrt(CS(n).Cxy);                %Monty Escabi, Dec 27 2006
            end
        
            %Estimating Significance Curve
            if flag==2

            	%Computing 0.05 and 0.01 confidence interval
            	
                    %Shuffled Coherence
                    Cxy=[CS(:).Cxy];
	
        			for m=1:size(Cxy,1)                      
                        %0.01 confidence interval
                        CXYsort=sort(Cxy(m,:));
                        NN=round(size(Cxy,2)*0.99);
                        Cs(k,l).C01(m,1)=CXYsort(NN);
                
                        %0.05 confidence interval
                        CXYsort=sort(Cxy(m,:));
                        NN=round(size(Cxy,2)*0.95);
                        Cs(k,l).C05(m,1)=CXYsort(NN);
                    end
            else

                %Computing 0.05 and 0.01 confidence interval (Fixed Threshold)
                
                	%Shuffled Coherence
                    Cxy=[CS.Cxy];
                    Cxy=reshape(Cxy,1,size(Cxy,1)*size(Cxy,2));
	
                    %0.01 confidence interval
                    CXYsort=sort(Cxy);
                    NN=round(length(Cxy)*0.99);
                    Cs(k,l).C01=CXYsort(NN)*ones(size(CS(1).Cxy));
                
                    %0.05 confidence interval
                    CXYsort=sort(Cxy);
                    NN=round(length(Cxy)*0.95);
                    Cs(k,l).C05=CXYsort(NN)*ones(size(CS(1).Cxy))
            end

            %Setting Flag
            FLAG(chan1(k),chan2(l))=1;
            
        end
        
            %Displaying Progress
            clc
            disp(['Correrlating Channels: ' int2str(k) ' vs. ' int2str(l)])
            disp(['Progress:              ' int2str(((k-1)*length(chan2)+l)/length(chan1)/length(chan2)*100) ' % Finished '])
            
    end
end
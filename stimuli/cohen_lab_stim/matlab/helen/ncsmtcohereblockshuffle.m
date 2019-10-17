%
%function  [CMTs]=ncsmtcohereblockshuffle(Data,chan1,chan2,NW,N,flag)
%
%DESCRIPTION: Shuffled Coherences for multi channel data from NCS file.
%             Uses blocked data which is not concatenated into a single
%             stream. Data is read with WAV2NCSDATABLOCKED.
%
%   Data        : Data structure containg all NCS channels from single 
%                 recording session (obtained using READALLNCS)
%   chan1       : Array of reference channels to correlate
%   chan2       : Array of secondary channesl to correlate
%   NW          : Number of tapers to use (Default==8)
%   N           : Number of shuffling itterations (Default==250)
%   flag        : Significance criterion
%                 1: Fixed Threshold (Default)
%                 2: Frequency Dependent Threshold
%
%RETURNED VARIABLES
%
%   CMTs        : Shuffled Coherence Data Structure (For significance Analysis)
%                 .Block(m).C01 : 0.01 confidence interval
%                 .Block(m).C05 : 0.05 confidence interval
%                 .ADChannels	: Channels used for coherence estimates
%                 .Faxis		: Frequency Axis		
%
% (C) Monty A. Escabi, April 2007
%
function  [CMTs]=ncsmtcohereblockshuffle(Data,chan1,chan2,NW,N,flag)

%Input Arguments
if nargin<4
    NW=8;
end
if nargin<5
    N=250;
end
if nargin<6
	flag=1;
end

%Sampling Rate 
Fs=Data(1).Fs;

%Quantized Amplitude Scaling Factor
dA=Data(1).ADBitVolts;

%Flag - Used to minimize the number of coherence calculations
Max=max([chan1 chan2]);
FLAG=zeros(Max,Max);

%Computing Coherence
for k=1:length(chan1)
	for l=1:length(chan2)
        for m=1:length(Data(1).Block)
        
            if FLAG(chan2(l),chan1(k))
                %Copying Coherence Data
                index2=find(chan1(k)==chan2);
                index1=find(chan2(l)==chan1);
                CMTs(k,l)=CMTs(index1,index2);
            
                %Setting Flag
                FLAG(chan1(k),chan2(l))=1;
            else
                %Shuffling
                for n=1:N
                    %Shuffled Coherence Estimate
                    X1=randphasespec(Data(chan1(k)).Block(m).X);
                    X2=randphasespec(Data(chan2(l)).Block(m).X);
                
                    %Coherence Estimate
                    [CMTs(k,l).Faxis,CS(n).Cxy]=...
                    	cmtm(dA*X1,dA*X2,1/Fs,NW);
                    CMTs(k,l).ADChannels=...
                    	[Data(chan1(k)).ADChannel Data(chan2(l)).ADChannel];    
                    
                    %Changing Dimensions
                    CS(n).Cxy=CS(n).Cxy';, CMTs(k,l).Faxis=CMTs(k,l).Faxis';
                end
        
                %Estimating Significance Curve
                if flag==2

                    %Computing 0.05 and 0.01 confidence interval
            	
                    %Shuffled Coherence
                    Cxy=[CS(:).Cxy];
	
                    for n=1:size(Cxy,1)                      
                        %0.01 confidence interval
                        CXYsort=sort(Cxy(n,:));
                        NN=round(size(Cxy,2)*0.99);
                        CMTs(k,l).Block(m).C01(n,1)=CXYsort(NN);
                
                        %0.05 confidence interval
                        CXYsort=sort(Cxy(n,:));
                        NN=round(size(Cxy,2)*0.95);
                        CMTs(k,l).Block(m).C05(n,1)=CXYsort(NN);
                    end
                else

                    %Computing 0.05 and 0.01 confidence interval (Fixed Threshold)
                
                	%Shuffled Coherence
                    Cxy=[CS.Cxy];
                    Cxy=reshape(Cxy,1,size(Cxy,1)*size(Cxy,2));
	
                    %0.01 confidence interval
                    CXYsort=sort(Cxy);
                    NN=round(length(Cxy)*0.99);
                    CMTs(k,l).Block(m).C01=CXYsort(NN)*ones(size(CS(1).Cxy));
                
                    %0.05 confidence interval
                    CXYsort=sort(Cxy);
                    NN=round(length(Cxy)*0.95);
                    CMTs(k,l).Block(m).C05=CXYsort(NN)*ones(size(CS(1).Cxy));
                end
            end
        end
        
        %Setting Flag
        FLAG(chan1(k),chan2(l))=1;
            
        %Displaying Progress
        clc
        disp(['Correrlating Channels: ' int2str(k) ' vs. ' int2str(l)])
        disp(['Progress:              ' int2str(((k-1)*length(chan2)+l)/length(chan1)/length(chan2)*100) ' % Finished '])
       
    end
end
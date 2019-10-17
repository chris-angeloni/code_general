%
%function [ValidData] = bayesclassifiernetwork(Aud,Fsd,L)
%
%	FILE NAME 	: BAYES CLASSIFIER NETWORK
%	DESCRIPTION : Performs naive bayesian classification on the output of a
%                 sound recognition spiking network
%
%	Aud(k,l,m)  : Data structure matrix containng network outputs as a
%                 function of words (k), subjects (l), trials (m)
%
%                 .Layer(n) - Resposne for different Network layers (1-6). 
%                          
%                 .Layer(n).Y
%   Fsd         : Desired sampling rate for spikes (Default==1000)
%   L           : Layer to do classification (Default==6)
%
%   RETURNED VARIABLES
%
%   ValData     : Data structure containing validation results
%
%                 .PredictedClass       - Predicted category
%                 .ActualClass          - Actual category
%                 .Classification Rate  - Percent correct word
%                                         classification rate
%                 .Pprior               - Prior distribution shown as a
%                                         probability response map
%
% (C) Monty A. Escabi, Martch 2015
%
function [ValData] = bayesclassifiernetwork(Aud,Fsd,L)

%Input Args
if nargin<2
    Fsd=1000;
end
if nargin<3
    L=6;
end

%Original Sampling Rate
Fs=2959

%Converting Response Data to matrix format
N1=size(Aud,1);
N2=size(Aud,2);
N3=size(Aud,3);
[L1,L2]=size(cell2mat(Aud(1,1,1).Layer(6).Y));
R=zeros(L1,ceil(L2/Fs*Fsd)+1,N1,N2,N3);
for k=1:N1              %words
    for l=1:N2          %subjects 
        for m=1:N3      %trials
            
            %Converting Response to matrix
            [i,j]=find(cell2mat(Aud(k,l,m).Layer(L).Y));
            j=round(j/Fs*Fsd)+1;        %Add +1 so that you dont get an index of 0
            for n=1:length(i)
                R(i(n),j(n),k,l,m)=1;
            end
        end
    end
end

%Building Priors including all sounds
Pprior=mean(mean(R,5),4);

%Classification and Validation
N1=size(R,1);           %Frequency channels/neurons
N2=size(R,2);           %Time samples
N3=size(R,3);           %Words
N4=size(R,4);           %Subjects
N5=size(R,5);           %Trials
for l=1:N3              %words
    for m=1:N4          %subjects
        for n=1:N5      %trials
    
            %Selecting Validation Response (acros all words, subject and trials)
            Rval=R(:,:,l,m,n);

            %Generating Pprior after removing validation dataset
            %Note that we need to subtract out the validation data being used
            Ppri=Pprior;
            Ppri(:,:,l)=(Pprior(:,:,l)*N4*N5-Rval)/(N4*N5-1);
         
            %Generating Posteriori Distribution
            Ppost=zeros(N3,N1,N2);      %Posteriori Distribution
            for i=1:N3  %words
                Pp=Ppri(:,:,i);         %Prior distribution for i-th word
                is=find(Rval~=0);       %Find responses with spikes
                Ppost(i,is)=Pp(is);     %Posteriori distribution for samples with spikes
                iz=find(Rval==0);       %Find zero valued responses
                Ppost(i,iz)=(1-Pp(iz)); %Posteriori distribution for samples with zero (no spike)
            end

            %Find probabilities == 0 within posteriori. If found replace with the Minimum/10 as a
            %penalty. This is done because log(posteriori) of 0 is -Inf and because
            %there are potentially random sammpling errors due to finite data that
            %could lead to such a scenario
            Min=min(Ppost(find(Ppost~=0)));
            i=find(Ppost==0);
            Ppost(i)=Min/10;

            %Classification to maximize the log-likelihood
            ValData.PredictedClass(l,m,n)=find(sum(sum(log10(Ppost),2),3)==max(sum(sum(log10(Ppost),2),3)));
            ValData.ActualClass(l,m,n)=l;
    
        end
    end
end

%Adding classification rate and prior to data structure
ValData.ClassificationRate=length(find(ValData.PredictedClass==ValData.ActualClass))/numel(ValData.ActualClass);
ValData.Pprior=Ppri;
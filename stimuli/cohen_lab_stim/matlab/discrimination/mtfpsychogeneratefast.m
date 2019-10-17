%
% function [MTF] = mtfpsychogeneratefast(Data,Fsd,tc,FM,GAMMA,TD,OnsetT,Unit)
%
%	FILE NAME 	: MTF PSYCHO GENERATE
%	DESCRIPTION : Generates a 'psychophysical' equivalent MTF. For each
%                 modulation condition (modulation frequency and index)
%                 computes the Van Rossum spike distance metric (SDM) 
%                 referenced on a signal with modulation index of 0. The
%                 SDM is then normalized as a discrimination index
%                 (D-prime).
%
%	Data        : Data structure obtained using "READTANK"
%                 Data is formated as follows:
%
%                   Data.Snips              - Snipet Waveforms
%                   Data.Fs                 - Sampling Rate
%                   Data.SnipsTimeStamp     - Snipet Time Stamps
%                   Data.SortCode           - Sort Code for the Snipets
%                   Data.ChannelNumber      - Channel Number for the Snipets
%                   Data.Trig               - Trigger Event Times
%                   Data.Attenuation        - Event Attenuation Level
%                   Data.Frequency          - Event Frequency 
%                   Data.StimOff            - Stimulus Offset Time
%                   Data.StimOn             - Stimulus Onset Time
%                   Data.EventTimeStanp     - Event Time Stamp
%
%   Fsd         : Desired sampling rate for analysis (Hz)
%   tc          : Time constant for computing spike distance (msec)
%   FM          : Modulation Rate Sequency (From Param.mat File)
%   GAMMA       : Modulation Index Sequency (From Param.mat File)
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%   Unit        : Unit Number
%
% RETURNED DATA
%
%   MTF         : MTF Data Structure
%
%                   MTF.Dp          - Raster Structure for each FM
%                   MTF.FMAxis      - Modulation frequency axis
%                   MTF.GammaAxis   - Modulation index axis
%
%   (C) Monty A. Escabi, March 2009 (Escabi Edit 7/13)
%
function [MTF] = mtfpsychogeneratefast(Data,Fsd,tc,FM,GAMMA,TD,OnsetT,Unit)

%Generating Psych Rastergram
[PsychRAS] = mtfpsychoraster(Data,FM,GAMMA,TD,OnsetT,Unit);
FMAxis=PsychRAS.FMAxis;
GAMMAAxis=PsychRAS.GAMMAAxis;

%Selecting Reference Noise Segments - Zero Modulation Index
RefRAS=[];
for k=1:size(PsychRAS,1)
    RefRAS=[RefRAS PsychRAS(k,1).RASTER];
end

%Selecting Data Segments
GAMMAAxis=GAMMAAxis(2:length(GAMMAAxis));
PsychRAS=PsychRAS(:,2:size(PsychRAS,2));

%Generating Distance for reference signal - can be done outside loop - much
%faster implementation
[D22]=sdmraster(RefRAS,RefRAS,Fsd,tc);

%Computing D-Prime MTF
for k=1:size(PsychRAS,1)
    for l=1:size(PsychRAS,2)
        %Finding desired AM condition
        i=find(GAMMAAxis(l)==[PsychRAS.GAMMA] & FMAxis(k)==[PsychRAS.FM]);
        
        %Generating Dprime
        [D12]=sdmpsth(PsychRAS(k,l).RASTER,RefRAS,Fsd,tc);      %Distance between PSTH (mean)
        %[D12]=sdmraster(PsychRAS(k,l).RASTER,RefRAS,Fsd,tc);
        [D11]=sdmraster(PsychRAS(k,l).RASTER,PsychRAS(k,l).RASTER,Fsd,tc);    

        %Computing Squared Norms and Dprime
        %Need 1/2 for N11 and N12 because we are computing the SDM for
        %different trials. Note that the response is of the form s1=s+n1
        %and s2=s+n2. When we compute SDM between s1 and s2 we have
        %SDM=norm(s2-s1)=norm(n2-n1)=2*var(n). So the estimate of variance
        %needs to account for the factor of 2
%        N12=mean(reshape(D12,1,numel(D12)));
        N12=D12;
        N11=1/2*sum(reshape(D11,1,numel(D11)))/(numel(D11)-size(D11,1));
        N22=1/2*sum(reshape(D22,1,numel(D22)))/(numel(D22)-size(D22,1)); 
        MTF.Dp(k,l)=sqrt(2)*sqrt(N12)/sqrt(N11+N22);                    %Escabi Edit 7/13, change 2 -> sqrt(2)
        
        [FMAxis(k) GAMMAAxis(l)]
        %clc
        %disp(['Computing PsychoMTF: ' num2str(100*( l+(k-1)*size(PsychRAS,2) )/numel(PsychRAS),3) ' % done'])
    end
end
MTF.FMAxis=FMAxis;
MTF.GammaAxis=GAMMAAxis;
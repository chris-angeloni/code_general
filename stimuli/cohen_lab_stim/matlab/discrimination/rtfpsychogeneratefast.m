%
% function [MTF] = rtfpsychogeneratefast(Data,Fsd,tc,FM,RD,GAMMA,TD,OnsetT,Unit)
%
%	FILE NAME 	: RTF PSYCHO GENERATE
%	DESCRIPTION : Generates a 'psychophysical' equivalent RTF. For each
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
%   FM          : Modulation Rate Sequence (From Param.mat File)
%   RD          : Ripple Density Sequence (From Param.mat File)
%   GAMMA       : Modulation Index Sequency (From Param.mat File)
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%   Unit        : Unit Number
%
% RETURNED DATA
%
%   RTF	        : RTF Data Structure
%
%                   RTF.Dp          - Raster Structure for each FM and RD
%                   RTF.FMAxis      - Modulation frequency axis (Hz)
%                   RTF.RDAxis      - Ripple density axis (cycles/oct)
%                   RTF.GammaAxis   - Modulation index axis
%
%   (C) Monty A. Escabi, June 2009 (Escabi Edit 7/13)
%
function [RTF] = rtfpsychogeneratefast(Data,Fsd,tc,FM,RD,GAMMA,TD,OnsetT,Unit)

%Generating Psych Rastergram
[PsychRAS] = rtfpsychoraster(Data,FM,RD,GAMMA,TD,OnsetT,Unit);
FMAxis=PsychRAS.FMAxis;
RDAxis=PsychRAS.RDAxis;
GAMMAAxis=PsychRAS.GAMMAAxis;

%Selecting Reference Noise Segments - Zero Modulation Index
RefRAS=[];
for k=1:size(PsychRAS,1)
    for l=1:size(PsychRAS,2)
        RefRAS=[RefRAS PsychRAS(k,l,1).RASTER];
    end
end

%Selecting Data Segments
GAMMAAxis=GAMMAAxis(2:length(GAMMAAxis));
PsychRAS=PsychRAS(:,:,2:size(PsychRAS,3));

%Generating Distance for reference signal - can be done outside loop - much
%faster implementation
[D22]=sdmraster(RefRAS,RefRAS,Fsd,tc);

%Computing D-Prime RTF
for k=1:size(PsychRAS,1)
    for l=1:size(PsychRAS,2)
        for m=1:size(PsychRAS,3)
            
            %Finding desired Ripple condition
            i=find(FMAxis(k)==[PsychRAS.FM] & RDAxis(l)==[PsychRAS.RD] & GAMMAAxis(m)==[PsychRAS.GAMMA]);

            %Generating Dprime
            [D12]=sdmpsth(PsychRAS(k,l,m).RASTER,RefRAS,Fsd,tc);      %Distance between PSTH (mean)
            %[D12]=sdmraster(PsychRAS(k,l,m).RASTER,RefRAS,Fsd,tc);
            [D11]=sdmraster(PsychRAS(k,l,m).RASTER,PsychRAS(k,l,m).RASTER,Fsd,tc);    

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
            RTF.Dp(k,l,m)=sqrt(2)*sqrt(N12)/sqrt(N11+N22);                  %Escabi Edit 7/13, change 2 -> sqrt(2)

            [FMAxis(k) RDAxis(l) GAMMAAxis(m)]
            %clc
            %disp(['Computing PsychoRTF: ' num2str(100*( l+(k-1)*size(PsychRAS,2) )/numel(PsychRAS),3) ' % done'])

        end
    end
end
RTF.FMAxis=FMAxis;
RTF.RDAxis=RDAxis;
RTF.GammaAxis=GAMMAAxis;
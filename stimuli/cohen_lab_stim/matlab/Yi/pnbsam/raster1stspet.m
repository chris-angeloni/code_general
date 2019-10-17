function [RAS1tt,RAS1spet,RAS2tt,RAS2spet]=raster1stspet(RAStt,RASspet,FMAxis,Flag,stimmod,onset,num)

% DESCRIPTION   : Generate RASTER for only 1st spet of every event
%   onset       : Cycle to remove at onset 
%   num        : the number of cycles that want. numC=0,take all
%   FMAxis      : FM 
%	RASspet	    : compressed spet RASTER format
%                .spet         - spike event time 
%                .Fs:          - sampling rate
%   RAStt       : time vs trial RASTER format
%                .time         - spike time
%                .trial        -
%                .N            - repetition

%
% RETURNED DATA
% RAS1spet, RAS1tt : RASTER of 1st spike every event  
% RAS2spet, RAS2tt : RASTER of except 1st spike every event

% Yi Zheng, Dec 2006

RAS1tt.N = RAStt.N;
RAS1tt.time =[];
RAS1tt.trial = [];
RAS2tt.time = [];
RAS2tt.trial = [];

for FMindex = 1:length(FMAxis)
    FM=FMAxis(FMindex)
    for n = (RAS1tt.N*FMindex-RAS1tt.N+1):(RAS1tt.N*FMindex)
        SpikeTime = RAStt.time(find(RAStt.trial==n));
        time1=[];
        if strcmp(stimmod,'cyc')
            if Flag==2
                latency1=min(SpikeTime);
                time1=[time1 latency1];
            else
            for c=onset:(onset+num)
                latency1 = min(SpikeTime(find((SpikeTime>c/FM)&(SpikeTime<(c+1)/FM)) ));
                time1 =[time1 latency1];
            end
            end % end of Flag==2
        else strcmp(stimmod, 'duration')
            for c=round(onset*FM):round((onset+num)*FM)
            latency1 = min(SpikeTime(find((SpikeTime>c/FM)&(SpikeTime<(c+1)/FM)) ));
            time1=[time1 latency1];
            end
        end  % end of if
        RAS1tt.trial=[RAS1tt.trial n*ones(1,length(time1))];
        RAS1tt.time=[RAS1tt.time time1];
        
        time2=SpikeTime(find(SpikeTime>time1|SpikeTime<time1));
%         if isempty(time2)
%             time2 = 0;
%         end
        RAS2tt.trial=[RAS2tt.trial n*ones(1,length(time2))];
        RAS2tt.time=[RAS2tt.time time2];
        
    end % end of n
end % end of FMindex
subplot(211)
plot(RAS1tt.time, RAS1tt.trial,'r.');
title('1st spike')
subplot(212)
plot(RAS2tt.time, RAS2tt.trial,'r.');
title('following spikes')

RAS1spet = [];
RAS1spet = rastertimetrial2spet(RAS1tt,RASspet(1).Fs,length(RASspet))
RAS2spet = []
RAS2spet = rastertimetrial2spet(RAS2tt,RASspet(1).Fs)
for i=(length(RAS2spet)+1):(RAStt.N*length(FMAxis))
    RAS2spet(i).spet=[];
    RAS2spet(i).Fs=RASspet(i).Fs;
end

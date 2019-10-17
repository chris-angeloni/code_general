%function convertSGSR2Monty(dataFile, seqnum, seqtype)
%
%Description: converts SGSR style data into a format that Monty's programs
%can use. Right now, converts random envelope data collected using wav
%files or vasms/nms sequences (based on the user input)
%
%
%Notes: there will be some issues with the durations because of our
%binaural/contra in one sequence paradigm. I'm not sure what to do with
%that info right now.

function [RASData modFreq] = convertSAMfromSGSR2Monty(dataFile, seqnum)

load(dataFile,'-mat');

seqStr = 'Sequence000';
seqNumStr = num2str(seqnum);
seqStr(end-length(seqNumStr)+1:end) = seqNumStr;
Sequence = eval(seqStr);

Order=Sequence.Header.PlayOrder;
[~, Order] = sort(Order);
spt = Sequence.SpikeTimes.spikes.spt(Order,:);


modFreq = Sequence.Header.IndepVar.Values(Order);

Fs=Sequence.Header.RecordParams.samFreqs;
%this line gives you the stimulus duration, I use a string format to
%designate these durations so that we can make the more complicated
%bursting patterns.
% Sequence.Header.StimParams.indiv.stim{1}.duration;

N1=size(spt,1);
N2=size(spt,2);
for k1 = 1:N1
    for k2 = 1:N2
        spet=round(Fs*(spt{k1,k2})/1000);
        RASData.Est(k2+(k1-1)*N2).spet=spet;
        RASData.Est(k2+(k1-1)*N2).Fs=Fs;
        RASData.Est(k2+(k1-1)*N2).Fm=modFreq(k1);
        RASData.Est(k2+(k1-1)*N2).T=Sequence.Header.StimParams.active;
    end   
end


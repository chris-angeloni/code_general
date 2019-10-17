%function [RASData SoundEstimationEnv SoundParam]= ...
%     convertRandEnvSGSR2Monty(sequences, txtdir, datafile, envfile, txtfilebase)
%
%Description: Converts Random Envelope data recorded with SGSR into a
%format usable by the function wienerkernelenv2input or similar
%
%Inputs:
%   sequences   : sequence numbers containing relevant data. Must be 
%                 ordered based on the wavlist number
%   txtdir      : directory containing the wavlist files, usually a network
%                 directory
%   datafile    : full path to the .SGSR format data file.
%   envfile     : full path to the .mat envelope file
%   txtfilebase : the filename of the wavlists before their ordering
%                 number,  ex: 'MergeFilesFreq3988HzBinPredEnvAnechoic Chamber80cm-90deg'
%
%Outputs:       See help from wienerkernelenv2input.

function [RASData SoundEstimationEnv SoundParam]= ...
    convertRandEnvSGSR2Monty(sequences, txtdir, datafile, envfile, txtfilebase)

lseqs = length(sequences);
load(datafile,'-mat');
load(envfile)
count = 1;
isPred = zeros(11,lseqs);
idx = zeros(11,lseqs);
for m = 1:lseqs
    if lseqs==1
        file = [txtdir txtfilebase '.wavlist'];
    else        
        file = [txtdir txtfilebase num2str(m) '.wavlist'];
    end
%     file = [txtdir 'MergeFilesFreq3988HzBinPredEnvAnechoic Chamber80cm-90deg' num2str(m) '.wavlist'];   
% 

    fid = fopen(file, 'rt');
    txt = textscan(fid, '%s', 'delimiter', '\n');
    txt = txt{1};    
    for n = 1:length(txt)
        isPred(n,m) = ~isempty(strfind(txt{n}, 'BinPredParadigm'));
        [~, name, ~] = fileparts(txt{n});
        idxstr = regexp(name, '\d+$', 'match');
        idx(n,m) = str2num(idxstr{1});
    end
    
    seqStr = 'Sequence000';
    seqNumStr = num2str(sequences(m));
    seqStr(end-length(seqNumStr)+1:end) = seqNumStr;
    Sequence = eval(seqStr);
    Fs=Sequence.Header.RecordParams.samFreqs;
    
%     isPred = isPred==1;
    Order=Sequence.Header.PlayOrder;
    [~, Order] = sort(Order);
    spt = Sequence.SpikeTimes.spikes.spt(Order,:);
    
        
    spt = spt(~isPred(:,m));
    
    for k = 1:size(spt,1)
        spet=round(Fs*(spt{k,1})/1000);
        index=find(spet/Fs<SoundParam.T);
        RASData.Est(count).spet=spet(index);
        RASData.Est(count).Fs=Fs;
        RASData.Est(count).T=SoundParam.T;
        count = count+1;
    end
    
    fclose(fid);
end

idx = idx(:);
idxEst = idx(~isPred(:));
[idxEst, orderEst] = sort(idxEst);

RASData.Est = RASData.Est(orderEst);


%ad hoc bs to fix the bad data (should have no effect on good data):
Est.spet = [];
Est.Fs = RASData.Est(1).Fs;
Est.T = RASData.Est(1).T;
RASDataNew.Est = repmat(Est, 1, 20);
RASDataNew.Est(idxEst) = RASData.Est;
RASData = RASDataNew;

for k=1:length(SoundEstimationEnv)
    SoundEstimationEnv(k).Env1=SoundEstimationEnv(k).Env;
    SoundEstimationEnv(k).Env2=fliplr(SoundEstimationEnv(k).Env);
end
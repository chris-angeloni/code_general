%addpath(genpath('~/chris-lab/code_general/'))

% NOTE: the way that the stimulus is made (dbs), the first row is
% the lowest frequency, last row is highest frequency
% load a stimulus design file
load(['180517-contrast-params.mat'])

% cleanly resample it to spike output resolution and normalize
S = cleanResample(dbs{1},params.chordDuration,1/200);
NS = (S - min(S(:))) / (max(S(:)) - min(S(:)));

% set the neurons tuning properties (these are set with a BF of
% 16kHz and sigma of 2 frequency bins in either direction)
% essentially, this builds a probability distribution over
% frequencies to determine the likelihood of a spike at that frequency
BF = 16000;
spikeProbs = normpdf(1:length(params.freqs),find(params.freqs==BF), ...
                     2);

% multiple the normalized stimulus by the spike probability and sum
% over all the frequency bins; then set a threshold for spiking
% (.65 works nicely I think)
bandP = sum(NS .* repmat(spikeProbs',1,length(NS)));
spikeInd = bandP > .65

% make spike times occur on average 20ms after the stimulus
% presentation with random jitter of 5ms
offset = .02;
jitter = .005;
spikeT = find(spikeInd>0)/1/200 + ...
         normrnd(offset,jitter,1,sum(spikeInd>0))

% generate the STA (the STA will be nFreqs x nTimeBins -- 34 x 21
% in my case, NOTE that becase the way the stimulus was made, the
% top frequency is the lowest frequency)
w = .1;
fps = 200;
spikes = spikeT(spikeT > .1);
STA = genSTA(spikes,S,w,fps);

% note that below, we flip the frequencies, this is because the
% plotting functions both flip the STA upside-down, so we want the
% frequency labels to match

% plot it using imagesc (the bin labels are incorrectly spaced!)
subplot(1,2,1)
t = (-w:1/fps:0) * 1000;
f = params.freqs / 1000;
imagesc(t,flipud(f),STA);
set(gca,'ydir','normal')
xlabel('Time (ms)');
ylabel('Frequency (kHz)');

% plot it using surf (the bin labels are correct)
subplot(1,2,2)
s = surf(t,flipud(f),STA);
s.EdgeColor = 'none';
set(gca,'yscale','log')
axis tight
view(2)
xlabel('Time (ms)');
ylabel('Frequency (kHz)');



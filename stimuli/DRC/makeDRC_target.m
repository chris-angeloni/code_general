function [stimf,events,amps,dB] = makeDRC_target(fs,rd,cd,d,F,MU,SD,amp70,ta,tt,Filt)

tic
% number of samples in ramps and chords
rs = rd * fs;
cs = (cd - rd) * fs;

% generate amplitude information for each contrast chunk
amps = [];
dB = [];
for i = 1:length(d)
    dBs = unifrnd(MU-SD(i),MU+SD(i),length(F),round(d(i) / cd));
    dB = [dB dBs];
    a = amp70 .* 10 .^ ((dBs-70)./20);
    amps = [amps a];
end

keyboard

% add in target amp and target time
mua = amp70 .* ...
    10 .^ ((MU-70)./20);
ind = round(tt) / cd;
amps(:,ind) = amps(:,ind) + (ta-mua);


% make a waveform
tdur = sum(d);
stim = zeros(1,round(fs*tdur));
t = 0:1/fs:tdur-(1/fs);
% for each frequency
for i = 1:length(F)
    %fprintf('FREQ = %g\n',params.freqs(i));
    % make a waveform
    f = sin(F(i)*t*pi*2);
    
    % make an amplitude envelope
    ampEnv = zeros(size(stim));
    for j = 1:size(amps,2)-1
        tmp = ones(1,cs) * amps(i,j);
        ramp = interp1([0 1],[amps(i,j) amps(i,j+1)],linspace(0,1, ...
                                                          rs));
        ind = (j-1:j)*(10000) + [1 0];
        ampEnv(ind(1):ind(2)) = [tmp ramp];
        
        % continue the last amplitude through
        if j == size(amps,2)-1
            ind = (j:j+1)*(10000) + [1 0];
            ampEnv(ind(1):ind(2)) = ones(1,cs+rs) * amps(i,j+1);
        end

    end
    
    stim = stim + (f .* ampEnv);
end


% ramp it
ramp = make_ramp(rs);
ramp = [ramp ones(1,length(stim) - (2*rs)) fliplr(ramp)];
stim = stim .* ramp;
stimf = conv(stim,Filt,'same');

pulseTime = .01;
events = zeros(1,length(stimf));
events([1:pulseTime*fs]) = 1;
toc


if 1==2
    figure
    subplot(2,1,1)
    imagesc(amps);
    subplot(2,1,2)
    hold on
    plot(t-3,stim);
    plot(t1-3,stimf);
    plot(t1-3,events);
    axis tight
    hold off
    drawnow
end

    
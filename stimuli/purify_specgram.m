function [amp, freq] = purify_specgram(S, width, samples, mask, amp_thresh)
% Use a ridge filter to find the dominant frequency for each time, and
% its approximate amplitude. Interpolate these to produce values for every
% sample of the original sound, rather than each time-step in the specgram.

siz = size(S);
numRows = siz(1);
amps = zeros(numRows,1);
freqs = zeros(numRows,1);

if ~exist('mask','var') || isempty(mask)
    mask = ones(numRows, 1);
end

if ~exist('amp_thresh','var') || isempty(amp_thresh)
    amp_thresh = 0;
end


for i=1:numRows,
    if mask(i)
        row = S(i,:);
        rc  = conv(row, ridge_filter(width), 'same');
        amps(i) = max(rc);
        freqs(i) = find(rc == amps(i), 1);
        if freqs(i) == 1 || freqs(i) == siz(2),
            amps(i) = 0;
        end
    else
        amps(i) = 0;
        %freqs(i) = 1;
    end
end

% Interpolate frequencies in low amplitude regions to avoid resampling
% artifacts

% First threshold the amplitudes
amps(amps <= amp_thresh) = 0;

if ~isempty(find(amps,1)),
    leftEdges = find( conv(double(amps ~= 0), [1, -1],'same') == -1 );
    rightEdges = find( conv(double(amps ~= 0), [1, -1],'same') == 1 );
    if amps(1) == 0,
        freqs(1:rightEdges(1)) = freqs(rightEdges(1)+1);
        rightEdges = rightEdges(2:end);
    end
    if amps(end) == 0,
        freqs((leftEdges(end)+1):end) = freqs(leftEdges(end));
    end
    leftEdges = leftEdges(1:(end-1)); % End counts as edge anyway
    for i=1:length(leftEdges),
        edges = [leftEdges(i), rightEdges(i)+1];
        freqs((leftEdges(i)+1):rightEdges(i)) = ...
            interp1( edges, freqs(edges), (edges(1)+1):(edges(2)-1) );
    end
    %subplot(2,1,1);stem(amps==0);subplot(2,1,2);plot(freqs);
end


% Enforce zero amplitude at boundaries
t1 = [0   (1:numRows)-.5   numRows];
t2 = linspace(0, numRows + 1 - 1/samples, samples);
amp = interp1(t1,[0; amps; 0],t2,'pchip');
% added gaussian smoothing 2/8/12
amp = smooth_array(amp,100);
freq= smooth_array( interp1(t1,[freqs(1);freqs;freqs(end)],t2,'pchip'),100);

amp = sqrt(amp);

freq(freq < 1) = 1;
freq(freq > siz(2)) = siz(2);

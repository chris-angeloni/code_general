function convSS = convSTRF(S,STA,mode)

% function convSS = convSTRF(S,STA)
% computes the linear combination of STA (neural filter) and the
% stimulus (S)
if ~exist('mode','var')
    mode = 'full';
end

convSS = zeros(1,size(S,2));
% for each frequency
for i = 1:size(S,1)
    % compute convolution of corresponding STA band and stim band
    x = conv(S(i,:), fliplr(STA(i,:)), mode);
    %x = x(floor(length(STA)/2)+1:end-floor(length(STA)/2));
    if strcmp(mode,'full')
        x = x(1:size(S,2));
        % account for conv shift by 1 sample
        x = [0 x(1:end-1)];
    end
    convSS = convSS + x;
end
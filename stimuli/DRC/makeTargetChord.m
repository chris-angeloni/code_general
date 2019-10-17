function [target, targetF] = makeTargetChord(params)

% make a target chord by choosing several values between each
% octave
octs = [4*1e3 .* 2 .^ (0:3) max(params.freqs)];
nchoices = [5 5 5 2];
target = zeros(1,length(params.freqs));
for k = 1:length(nchoices)
    % choose n between each bound
    ind(1) = find(params.freqs == octs(k));
    ind(2) = find(params.freqs == octs(k+1));
    ind = ind(1):ind(2);
    
    % choose n items separated by 1/5 octave
    cnt = 0;
    while 1
        cnt = cnt + 1;
        freq = randperm(length(ind)-1,nchoices(k));
        if ~any(diff(sort(freq))<=1) || isempty(diff(freq))
            break;
        end
    end
    length(freq);
    %fprintf('%d iterations\n',cnt);
    
    % build target variable
    target(ind(freq)) = 1;
end
targetF = params.freqs(target>0);

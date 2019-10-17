% Yi Zheng, 2006

% Analyze SAM, PNB and Onset

% rasterexpand       - raster expand to a matrix (for desired raster
% duration)
% rasterexpand2      - (for a period stimulus:onset)

% rastergen          - Generate raster in spet and time-trial format
% mtfrtgenerate      - Generate rate,normalized spet-per-event, temporal
%                      MTF

% rasterexpand       - Convert a spet raster to matrix format (0 and Fsd)
% cychgen            - Genrate CYCH
% psthgen            - Generate PSTH
% CF                 - find CF of neurons

% ------- Seperate onset and sustained components from SRN responses ------
% firstvs2ndspet     - Distribution of first and second spike time
% onsetsep           - Find the boundary to seperate onset and sustained
%                      components for a given frequencies
% sep1st2nd          - Seperate onset and sustained components based on the
%                      distribution of 1st and 2nd spike.
% sepsam             - Seperate SAM cych according to a known boundary 
% stvs2ndspet        - To see the relationship of the distribution of first
%                      and 2nd spike
% raster1stspet      - Generate RASTER for only 1st spet of every event
% seponsetsus        - Seperate onset and sustained component form ONSET
%                      response for all frequencies
% **** ROUTINE ****
% [RASspet, RAStt, FMAxis] = rastergen(Data,2,'cyc',0,1,0,100)
% [SPET2] = firstvs2ndspet(RASspet,FMAxis)
% [Bound,RASonset,RASsus]=sep1st2nd(SPET2,RASspet,FMAxis,2,'cyc',0,1)
% RASOnset(count,1:length(RASspet))=RASonset';
% RASSus(count,1:length(RASspet))=RASsus';

% ------- Shuffled correlation --------
% mtfcorrgenerate    - SC between raster trials
% cirwrapras         - Circular wrap raster
% booteimi           - bootstrap Rab to compute the mean and standard error
% of envelope index and modulation index
% rasterbrk          - break down the raster to designed cyc/trial
% mtfcorrgen4brkras  -
% mtfcorrgen4brkrasjack - Shuf-corr MTF using jackknife
% rastercircularxcorrfast - shuffled circular correlation

% -------- Reliabilty and Jitter ----------
% mtfjittergenerate  - Generate a Jitter & Reliability MTF
% reliagen           - Generate reliability MTF according the auto- and
%                      cross-correlation method.

% --------- Random raster ------------
% shuffleras        - Shuffle raster to generate random raster
% shufflerandspet   - Shuffle spikes with Poisson intervals
% shufflespet       - Shuffle spikes with random inter-spike intervals

%-----------Statistic ----------------
% routinesig        -
% sigtest           - significant test using ttest
% sortbythes        - sort units by threshold
% shufflespet       - generate shuffle raster
% meansdgen         - generate mean and sd of spike times
% bootpolynomial    - bootstrap polynomial slop and intercept


% ---------- d' ----------------
% dprimewave
% dprimemtf






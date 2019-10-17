% script INCLUDE_DEFS.m

% colors for message window at bottom of figure
MESSAGECOLOR = [.4 1 .4];    % green
ERRORCOLOR = [1 0.4 0.4];    % red
WARNCOLOR = [1 0.8 0.4];     % yellow
NORMCOLOR = [1 1 1];         % white

%  normal background color for buttons
NORMBUTTONCOLOR = [0.7 0.7 0.7];     % gray

% numbers that result from the tuning curve acquisition
% NFREQS = 45;                            % # of frequencies in tuning curve
% NAMPS = 15;                             % # of amplitudes in tuning curve
DEFAULT_AMP_MAX = 72.5;
DEFAULT_AMP_STEP = 5;
SAMP_RATE = 30;

% threshold for tuning curve edge suggestion (spikes)
EDGE_DETECT_THRESH = 0.75;  

% columns for attribute vector

FILENAME     =  1;      
CF           =  2;
THRESHOLD    =  3;
SPONT_EST    =  4;
SPONT_STD    =  5;

INFO10       =  6;
INFO20       = 11;
INFO30       = 16;
INFO40       = 21;

OFFSETQ      = 0;
OFFSETA      = 1;
OFFSETB      = 2;
OFFSETBW     = 3;
OFFSETASYM   = 4;

LATENCY      = 26; % from latency

MAXRATE      = 27;
MAXRATECF    = 28;
MAXRATECFAMP = 29;   
RATESLOPE1   = 30;   
RATESLOPE2   = 31;   
NONMONOTONIC = 32;
AMPATTRANS   = 33; % from rate

PK1PK        = 34; % from histogram
PK1END       = 35; 
PK2START     = 36;

% stuff added with ntc (not in original tcexplore)
ATTENC       = 37;
ATTENI       = 38;
DEPTH        = 39;
UNITNUM      = 40;
FILEDATE     = 41;
RATETHRESH   = 42;
RATEATTRANS  = 43;
AMPATFADE    = 44;
PK2END       = 45; 

NUMATTRIBUTES = PK2END;    % set this to the highest numbered index

PREFPROMPT = 1;
PREFVALUE = 2;
defaultPrefs = ...
 struct('dataDir',      {'data directory (* for current)',     '*'}, ...
        'dataFile',     {'data file (* for current)',          '*'}, ...
        'outputDir',    {'output directory (* for current)',   '*'},...
        'outputFile',   {'output file (* for current)',    		'*'}, ...
        'Time',         {'time ([start end] in ms)',           '[10.0 30.0]'}, ...
        'displayType',  {'display type (e.g., RasterByFreq)',  'Lines'}, ...
        'smoothType',   {'smooth type (e.g., Smooth2)',        'Smooth2'}, ...
        'blind',        {'blind (yes/no)',                     'no'}, ...
        'spontPercent', {'spontaneous percent (<0 for off)',   '100'}, ...
        'fixedSize',    {'fixed/float size (<0 for float)',    '-6'}, ...
        'defaultAtten', {['default atten. ([contra ipsi], dB,',...
	                 ' [* *] uses header on load)'],             '[30 99]'}, ...
        'axisLatency',  {'time axis limits for latency (ms)',  '[0 30]'}, ...
        'axisHistogram',{'time axis limits for histogram & rasters (ms)','[0 100]'}, ...
        'background',   {'background color (white/black)',     'white'}, ...
        'rateRawOnly',  {'raw data only for Rate? (yes/no)',   'yes'}, ...
        'halfWidth',    {'window half-width for latency detection (ms)', ...
                                                               '2.5'}, ...
        'sigProb',      {'probability level for latency detection', ...
                                                               '0.001'}, ...
        'applyOnLoad',  {'apply on every "load"? (yes/no)',    'yes'});

defColorOrder = [...
         0         0    1.0000; ...
         0    0.5000         0; ...
    1.0000         0         0; ...
         0    0.7500    0.7500; ...
    0.7500         0    0.7500; ...
    0.7500    0.7500         0; ...
    0.2500    0.2500    0.2500];

noCommentString = '<add comments here>';

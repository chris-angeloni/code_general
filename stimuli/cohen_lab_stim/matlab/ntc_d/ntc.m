function ntc()
% function ntc
%
% graphical user interface to analyze (well, "measure" really) tuning 
%    curve data
%
% ntc can read:
% -------------
%   dtc format
%   ntc native matlab format (see below)
%   matlab format from BrainWave (see below)
%
% output file formats:
% -------------------
% N.B.: THE 'APPEND' BUTTON MUST BE CLICKED AT LEAST ONCE BEFORE ANY DATA 
%       WILL BE PLACED IN THE OUTPUT ARRAY.
%  
% Output can be in MatLab (.mat) format or either of two types of ASCII text 
%   (.txt or .xls), selectable by the user at save time:
%  -- A .mat output file will contain a 1x1 cell array of user 'comments';  
%    an Ax1 cell array of 'column_labels', where A = the number of attributes 
%    in the output array (defined in INCLUDE_DEFS); and an NxA array of 'data', 
%    where N = the number of times that attributes were appended to the output;
%    ideally, this should equal the number of measured data files.
%  -- A .txt output file will contain two tab-separated columns of ASCII text:  
%    Attribute labels and the corresponding values.  Only the values from the
%    currently-loaded tuning curve are saved.
%  -- A .xls output file will contain multiple tab-separated columns of ASCII 
%    text:  One columnn of attribute labels and N columns of corresponding 
%    values, with N defined as above for .mat output.  Note:  '.xls' is the
%    default filetype extension for Excel for Windows.  Excel and most other 
%    spreadsheet programs will automatically recognize and import formatted
%    text from such files.
%   
%   The .mat output format is best if all subsequent analyses and statistical 
%   comparisons will be done using MatLab.  Text output formats allow the use 
%   of other programs (e.g. the UNIXstat package, StatGraphics, Excel, etc) as
%   well as MatLab for subsequent analyses.
%
%
% input file formats:
% -------------------
%   dtc format --
%     binary format produced by you-know-what
%
%   ntc native matlab format --
%     must include matrix 'latencies', scalars 'fMin', 'nOctaves', 'extAtten',
%         'NAMPS', and 'NFREQS'
%       latencies:  Nx3 matrix  
%                   column 1 is spike latency 
%                   column 2 is frequency index (e.g., an integer from 1-45)
%                   column 3 is amplitude index (e.g., an integer from 1-15)
%       fMin:       lowest stimulus frequency (Hz)
%       nOctaves:   number of frequency octaves covered by stimuli
%       extAtten:   external attenuator setting (dB)
%       NAMPS:      number of stimulus amplitudes (e.g., 15)
%       NFREQS:     number of stimulus frequencies (e.g., 45)
%    optional: may include character string 'header', analogous to the comment
%      string entered when saving data file (e.g., 'U21 FTC -20C/-20I 1037UM')
%
%  matlab format from BrainWave --
%    must include scalars 'duration', vectors 'frequency' and 'amps', and a
%        bunch of time-slice matrices 't1' - 'tn'
%      duration:     integer indicating the last time slice matrix (msec)
%                    (e.g., duration=50 --> file holds time slice matrices t1-t50))
%      frequency:    vector containing stimulus frequencies (Hz, low to high)
%      amps:         vector containing stimulus amplitudes (dB, low to high)
%      t1, t2, etc.: logical (can be sparse) matrices, numeric part of name 
%                    indicates time slice (msec), 0 entries indicate no spikes
%                    for that stimulus, non-zero entries indicate spike(s) 
%                    occurred during that time slice for that stimulus.  one row
%                    per stimulus amplitude, one column per stimulus frequency.
%                    ***                                                    ***
%                    *** N.B. - during translation, any matrix entry > 0 is ***
%                    *** interpreted as a SINGLE spike                      ***
%                    ***                                                    ***
%
%   See also TCEXPLORE.

%   Copyright (c) 1997-99 by The Regents of the University of California


global ntcPrefs;

INCLUDE_DEFS;
newDoTC;

ntcPrefs = defaultPrefs;
if exist('./ntcprefs.mat', 'file')==2,
    load('./ntcprefs.mat','ntcPrefs');
end;
  
return

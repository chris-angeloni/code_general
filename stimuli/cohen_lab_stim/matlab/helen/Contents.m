%  MATLAB GUI FOR EEG REVIEW
%  Copyright    Angel(ANQI QIU)
%             7/24/2001
%
%
%  REVIEW EEG
%      revieweeg                 - Review EEG and filter EEG signal
%      openchannel               - open original data
%      openlfilter               - open data through a low pass filter
%      openbfilter               - open data through a band pass filter
%      dat2dat                   - convertion of data from experimental data to Matlab data
%      dat2dat_gui               - GUI for convertion of data from experimental data to Matlab data
%      filterconvert             - GUI for processing data through filters
%      convert_callback          - processing data of 16 channels through filters at the same time
%      filterdata                - processing data of one channel through filters
%      fdesign                   - filter design
%      h                         - filter design
%      lowpass                   - a low pass filter
%      bandpass                  - a band pass filter
%      startshow                 - start to show the curves
%      showbf                    - show curves back or forward
%      stopshow                  - stop to show and close all the channels
%
%  CORRELATION
%      eegcorr                   - correlation between data that come from two channels at the same time
%      ploteegcorr               - calculation of correlation and showing curve
%
%  LOADING FILES
%	readncs			 - Reads a single NCS file to MATLAB data structure
%	readallncs		 - Reads all NCS files in a directory using READNCS
%
%

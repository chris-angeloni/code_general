%Monty's Spectro-Temporal Analysis Toolbox
%Version 1.0   05-01-01
%Copyright (c) Monty A. Escabi, University of Connecticut
%
%Spectro-temporal sound analysis
%  bathagramfl    - Batches audigramfl (c program) - save as .ste file
%  spectempenv    - Spectro-Temporal Envelope - saved to .spg file
%  xtractspg      - Extracts spectro-temporal data segment from .spg file
%  xtractagram    - Extracts audiogram data segment from .ste files
%  audiogramres   - Audiogram filter bank resolution
%
%Spectrum Analaysis
%  psdfile        - Computes the Power Spectral Density of a .sw file
%  batchpsdfile   - Computes the Power Spectral Density of all .sw files in Dir
%
%Spectro-temporal Statistics
%  spectempsp     - Spectro-Temporal Envelope Spectrum (from .sw)
%  corrcoefagram  - Audiogram cross band correlation coefficient (.ste)
%  corrcoefsgram  - Spectrogram cross band correlation coefficient (.spg)
%  spectrumagram  - Audiogram mean spectrum (average over time) (.ste)
%
%Plotting Utils
% plotspectempamp - Plots Spectro-Temporal amplitude distribution of a sound
%
%Contrast Statistics
%  spgampdist     - Finds spec-temp amplitude dist from .spg file
%  agramampdist   - Finds spec-temp amplitude dist from .ste file
%  spectempamp    - Finds spec-temp amplitude dist from .sw file
%  ampdist        - Finds amplitude distribution of raw data from .sw file
%  batchampdist   - Batch file for ampdist, raw amplitude distribution from .sw
%  ampstdmean     - Finds Mean(t), Std(t) for the spec-temp contrast dist, C(t)
%  ampdrescale    - Rescales the C(t) distribution by averaging N time points
%  ampdistbreak   - Finds relevant sound segments from the contrast dist , C(t)
%  ensampstat     - Finds Ensemble Amplitude Statistics from .spg filies
%
%Batch Files
% bathagramfl     - Batches audigramfl (c program) - save as .ste file
% batchspectempenv- Batch file for SPECTEMPENV
% batchampdist    - Batch file for AMPDIST, raw amplitude distribution from .sw
% batchspgampdist - Batch file for SPGAMPDIST, 
%batchagramampdist- Batch file for AGRAMAMPDIST, 
% batchpsdfile    - Computes the Power Spectral Density of all .sw files in Dir
%
%Other
% cirticalband    - Finds cutoff freq. for a 1/3 oct critical band filter bank
% agramlin2db     - Converts an 'ste' dta segment from Lin to dB
%

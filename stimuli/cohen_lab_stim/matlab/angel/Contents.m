%  Matlab toolbox for Sound and Speech research 
%  Version 1.0  2/02/2001
%  Copyright (c) Anqi Qiu, Uconn
%  
%
%  Hodgkin and Huxley model
%
%    Hodgkin.mdl                 - Hodgkin and Huxley Model(1952)
%    Gna.mdl                     - caculation of sodium conductance
%    Gk.mdl                      - caculation of potassium conductance
%    Hodgkin1                    - Analysis of Hodgkin and Huxley Model
%    HHmodel1                    - Analysis of Hodgkin and Huxley Model
%    action_potential            - plot Hodgkin model's parameter
%    ananoise                    - effect of Gaussian noise on spike rate 
%    current_rate                - analysis of relationship between current and spike rate
%    refractory                  - refractory period after action potential
%    current_sine                - analysis of spectral response of Hodgkin model
%
%  Sandwich model
%    
%    sandwichmodel               - sandwich model in the auditory system
%    sandwichmodel1              - sandwich model and plot
%
%
%  Simulation of STRF and FSI
%
%    strfsimulate                - reconstruction of STRF using different sound and threshold for action potential
%    strfsimulate1               - the same as sprfsimulate.m, with strfsimulate_gui.m together.
%    strfsimulate_gui            - GUI for sprsimulate1.m
%    strfsimulate2               - reconstruction of STRF and calculate SI and FSI
%
%
% Database Demo
%    
%    trydbexportdemo             - export data from Matlab to try.mdb
%    trydbimportdemo             - import data from try.mdb to Matlab
%
%
% Model for reconstruction of STRF
%    strfmodel.m.old             - using a mathematical model to reconstruct STRF
%    strfmodel_ic                - to fit STRF or STRFs in the IC.
%    strfmodel_ctx.m.old         - to fit STRF or STRFs in the auditory cortex
%    gstrfmodel                  - *to fit STRFs
%    srfmodel                    - *to fit SRF profile
%    trfmodel                    - *to fit TRF profile
%    spectrofit                  - for non linear fit model  
%    tempofit                    - for non linear fit model
%    batchgstrfmodel             - *batch files in one directory into fitted STRF matlab file
%    gstrfmodelsave              - *to fit STRF1 and STRF2 for each file (*dB.mat and *Lin.mat)
%    rstrfstateigen              - to estimate level of noise on the STRF
%    strfnoisefun                - statistically analyze the level of noise on the STRF from results of rstrfstateigen.m
%    timeshift                   - to map taxis to a new axis
%
%
% Optimization of Intracellular parameters
%    strfoptmodel                - optimized intracellular parameters by local search
%    strfpreopt                  - optimized intracellular parameters by global search
%    batchstrfoptmodel           - finding intracellular parameters and prediction of response to RN and DR
%    batchstrfpreopt             - finding intracellular parameters and prediction of response to RN and DR
%



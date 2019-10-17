function [R]=findR(s,sd)

R=( sum(s.*s) - sum(sd.*sd) ) / sum(s.*sd) /2;

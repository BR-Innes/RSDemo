function [Xp, Yp, Zp, Bp] = feedRaceModel(file)  

% Takes the file name e.g. feedRaceModel('RS_Data.mat') and gives it to 
% RaceModel.m

load(file);

p = 0.05:0.05:0.95; % probabilities 
getRacePlot = 1; % whether we want a plot

try 
    [Xp, Yp, Zp, Bp] = RaceModel(aRTs', vRTs', avRTs', p, getRacePlot);
catch 
    disp('Couldn''t run the Race Model Test script!'); 
end 
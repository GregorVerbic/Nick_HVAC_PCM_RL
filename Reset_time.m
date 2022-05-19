%% Function handles the resetting of each episode
function [InitialObservation, LoggedSignal] = Reset_time()
load trainingdata.mat;

persistent ii
if isempty(ii)
    ii=0;
end
ii=ii+1;

initial_temp = Temperature(1,ii);
initial_time = 1;
LoggedSignal.State = [initial_temp; initial_time];
InitialObservation = LoggedSignal.State;
end






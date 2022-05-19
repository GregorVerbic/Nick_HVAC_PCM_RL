%% DDPG Agent for PCM Environment

clear; clear Reset_time; clear Step_time;
Inputdata;

%% Observation Info
obsInfo = rlNumericSpec([2 1]);
obsInfo.Name = 'Tin';
obsInfo.Description = ['indoor temperature, time'];
numObservations = obsInfo.Dimension(1);
%% Action Info
actInfo = rlNumericSpec([1],...
'LowerLimit',[0]',...
'UpperLimit',[1]');
actInfo.Name = 'heating';
numActions = numel(actInfo);

%% Setup Environment
ResetHandle = @ Reset_time; % reset initial observation before each episode recycle
StepHandle = @(Action,LoggedSignals) Step_time(Action,LoggedSignals); % calculate reward and next observation 
env = rlFunctionEnv(obsInfo,actInfo,StepHandle,ResetHandle);
Ts = 1.0; %Time steps
Tf = 24; %Time
rng(0) %Reproducability

%% CRITIC
statePath = [imageInputLayer([numObservations 1 1],'Normalization','none','Name','State')
    fullyConnectedLayer(64,'Name','fc1')];
actionPath = [imageInputLayer([numActions 1 1], 'Normalization', 'none', 'Name','Action')
    fullyConnectedLayer(64, 'Name','fc2')];
commonPath = [additionLayer(2,'Name','add')
    reluLayer('Name','relu2')
    fullyConnectedLayer(32, 'Name','fc3')
    reluLayer('Name','relu3')
    fullyConnectedLayer(16, 'Name','fc4')
    fullyConnectedLayer(1, 'Name','CriticOutput')];
criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork,statePath);
criticNetwork = addLayers(criticNetwork,actionPath);
criticNetwork = addLayers(criticNetwork,commonPath);
criticNetwork = connectLayers(criticNetwork,'fc1','add/in1');
criticNetwork = connectLayers(criticNetwork,'fc2','add/in2');

criticOptions = rlRepresentationOptions('LearnRate',1e-4,'GradientThreshold',1);
critic = rlQValueRepresentation(criticNetwork,obsInfo,actInfo,...
    'Observation',{'State'},'Action',{'Action'},criticOptions);


%% ACTOR
actorNetwork = [imageInputLayer([numObservations 1 1],'Normalization','none','Name','State')
    fullyConnectedLayer(64, 'Name','actorFC1')
    tanhLayer('Name','tanh1')
    fullyConnectedLayer(32, 'Name','actorFC2')
    tanhLayer('Name','tanh2')
    fullyConnectedLayer(numActions,'Name','Action')
    tanhLayer('Name','tanh3')];
actorOptions = rlRepresentationOptions('LearnRate',1e-3,'GradientThreshold',1);
actor = rlDeterministicActorRepresentation(actorNetwork,obsInfo,actInfo,...
    'Observation',{'State'},'Action',{'tanh3'},actorOptions);

%% SETTINGS
opt = rlRepresentationOptions('UseDevice',"gpu");
agentOpts = rlDDPGAgentOptions(...
'SampleTime',Ts,...
'TargetSmoothFactor',1e-3,...
'DiscountFactor',0.99, ...
'MiniBatchSize',128, ...
'ExperienceBufferLength',1e6);


agent = rlDDPGAgent(actor,critic,agentOpts);
%% TRAINING
maxepisodes = 10000;
maxsteps = 24;
trainOpts = rlTrainingOptions(...
'MaxEpisodes',maxepisodes, ...
'MaxStepsPerEpisode',maxsteps, ...
'ScoreAveragingWindowLength',24, ...
'Verbose', false, ...
'Plots','training-progress',...
'StopTrainingCriteria','AverageReward',...
'StopTrainingValue',inf);

%% Training
doTraining = true;
if doTraining
   
% Train the agent.
trainingStats = train(agent,env,trainOpts);
else
% Load previous training results.
load('trainingoutput.mat','agent')
end


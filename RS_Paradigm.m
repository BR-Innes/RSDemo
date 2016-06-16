%% RS_Paradigm %%

% A basic Redundant Signals Paradigm to provide RT data that you can feed
% xto Ulrich et al.'s (2007) Race Model Inequality Test code. 

% Will require PsychToolBox; either a keyboard or RTBox for responses.
% Will also require RaceModel.m, the code written by Ulrich et al., if you 
% want the data to be plotted at the end. 

% EXPERIMENT OUTLINE: 
% 1: Waits for set period before each trial 
% 2: Presents either an auditory(a), visual(v), or redundant(av) stimulus
% 3: Waits a set time for response (here use 'x' key)
% 4: Waits a random time post-response to prevent anticipatory RTs

% BR-Innes 


%% SETUP %% 
%--------------------------------------------------------------------------
% EQUIPMENT SETUP 
%--------------------------------------------------------------------------

% Cleanup 
sca;
close all;
clearvars; 
GetSecs; % Call functions so subsequent calls aren't delayed
WaitSecs(0.001);

% Equipment used
useRTBox = 0; % 0 = keyboard, 1 = RTBox 

% Screen properties (cm)
sx = 51.5; % screen length
sy = 32.5; % screen height
sd = 57; % distance eye-screen

% Reponse keys 
if useRTBox == 1
    % setup particular buttons if needed here, otherwise any work
else 
    responseKey = KbName('x'); % pick a response key 
end 

%--------------------------------------------------------------------------
% VARIABLE SETUP  
%--------------------------------------------------------------------------

% Timing variables (s) 
preTrialT = 1; % time before stimulus
stimPresT = 0.1; % stimulus presentation time
maxWaitT = 1.5; % max. time to wait for RT before skipping 

% Trials
noTrialsPerCon = 20; % trials per contiditon  
expTrialSetup = [zeros(noTrialsPerCon, 1)+1; zeros(noTrialsPerCon, 1)+2;...  
    zeros(noTrialsPerCon, 1)+3]; % set up a trial order array 
shuffle = randperm(length(expTrialSetup))'; % set up a randomiser array

% Set up blank arrays for RT data and new trial order 
[targetStart, timeKeyPress, RTs, expTrialOrder] = ...
    deal(zeros(noTrialsPerCon*3, 1)); 

% Randomise trial order 
for i = 1:length(expTrialSetup)
    expTrialOrder(i, 1) = expTrialSetup(shuffle(i)); 
end  

%% EXPERIMENT START %% 
%--------------------------------------------------------------------------
% SET UP PTB SCREEN
%--------------------------------------------------------------------------
try   
    screenNumber = max(Screen('Screens'));
    
%     Screen('Preference', 'SkipSyncTests', 1);
%     Screen('Preference','SuppressAllWarnings', 1);
%     Screen('Preference','VisualDebugLevel', 0);

    % Get screen colors
    black = BlackIndex(screenNumber);
    white = WhiteIndex(screenNumber); 
     
    % Fullscreen for experiment
    [window, rect]= Screen('OpenWindow', screenNumber, black); 
    [winWidth, winHeight] = WindowSize(window);      
    HideCursor;
    
    % Find the size of the display
    DisplayXSize = rect(3);
    DisplayYSize = rect(4);
    midX = DisplayXSize/2;
    midY = DisplayYSize/2;
    
%--------------------------------------------------------------------------
% AUDITORY STIMULI SETUP 
% 
% Here I'm adapting code for a simple beep from Peter Scarfe's site:
% http://peterscarfe.com/beepdemo.html
%--------------------------------------------------------------------------

    % Initialize Sounddriver
    InitializePsychSound(1);
    nrchannels = 2;
    freq = 48000;

    % How many times to we wish to play the sound
    repetitions = 1;

    % Length of the beep
    beepLengthSecs = stimPresT;

    % Start immediately (0 = immediately)
    startCue = 0;

    % Should we wait for the device to really start (1 = yes)
    % INFO: See help PsychPortAudio
    waitForDeviceStart = 1;

    % Open Psych-Audio port, with the follow arguements
    % (1) [] = default sound device
    % (2) 1 = sound playback only
    % (3) 1 = default level of latency
    % (4) Requested frequency in samples per second
    % (5) 2 = stereo putput
    pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);

    % Set the volume to half for this demo
    PsychPortAudio('Volume', pahandle, 0.2);

    % Make a beep which we will play back to the user
    myBeep = MakeBeep(500, beepLengthSecs, freq);

    % Fill the audio playback buffer with the audio data, doubled for 
    % stereo presentation
    PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);

%--------------------------------------------------------------------------
% VISUAL STIMULI SETUP 
%
% Here I'm just presenting a small square of size X degrees. 
% The colour is currently the white index (above) but can be changed to 
% something else here. 
%--------------------------------------------------------------------------

    vTargetSize = 1; % no. degrees visual angle
    
    %find pixels/cm
    vadxcm=DisplayXSize/sx; % pixels per cm
    vadycm=DisplayYSize/sy;
    
    % Find pixels/degree
    vadx=vadxcm/(atan(1/sd)*180/pi); % for one degree visual angle
    vady=vadycm/(atan(1/sd)*180/pi); 
    
    % Visual stimuli co-ordinates
    vTargetX = vadx*vTargetSize; % this many degrees wide
    vTargetY = vady*vTargetSize; % this many high
    vTargetCood = [-vTargetX -vTargetY vTargetX vTargetY];
    vTargetCood = CenterRect(vTargetCood, rect); % centre the square
    
    % Set colour
    colourStim = white; 

%--------------------------------------------------------------------------
% TITLE SCREEN 
%--------------------------------------------------------------------------
    
    % Test beep 
    PsychPortAudio('Start', pahandle, repetitions, startCue,... 
                waitForDeviceStart);
    PsychPortAudio('Stop', pahandle);
    WaitSecs(0.2); 
    
    % Title Screen 
    Screen('FillRect', window, black);
    Screen('TextStyle', window, 0); %normal
    Screen('TextFont', window, 'Lucida Console');
    text = 'Press any key to start task';
    width = RectWidth(Screen ('TextBounds', window, text));
    Screen('DrawText', window, text, DisplayXSize/2 - width/2,...
            DisplayYSize/2, white); 
    Screen('Flip', window); 
    
    % Wait for a keypress 
    while KbCheck;
    end % wait for all keys are released
    keyisdown = 0;
    while ~keyisdown
        [keyisdown] = KbCheck;
        WaitSecs(0.001); % delay to prevent CPU hogging
    end
    
    % Start Experiment 
    Screen('Flip', window);
    
%% EXPERIMENT LOOP 
%--------------------------------------------------------------------------
% STIMULUS PRESENTATION LOOP  
%--------------------------------------------------------------------------
    
    for i = 1:length(expTrialOrder)
        
        % Wait for keys to be released
        while KbCheck;
        end
        keyisdown = 0;
        
        % Wait set time before trial 
        WaitSecs(preTrialT);
        
        % Clear RTBox for using this  
        if useRTBox == 1
            RTBox('Clear', 5);
        end 
        
        % Present Stimulus 
        if expTrialOrder(i, 1) == 1 % i.e. auditory trial 
            PsychPortAudio('Start', pahandle, repetitions, startCue,... 
                waitForDeviceStart); % play it 
            targetStart(i) = GetSecs; % record target start time
        elseif expTrialOrder(i, 1) == 2 % i.e. visual trial 
            Screen('FillRect', window, colourStim, vTargetCood);
            Screen('Flip', window); % show it 
            targetStart(i) = GetSecs; 
            WaitSecs(stimPresT);
            Screen('Flip', window);
        elseif expTrialOrder (i, 1) == 3  % i.e. redundant trial 
            PsychPortAudio('Start', pahandle, repetitions, startCue,...
                    waitForDeviceStart);
            Screen('FillRect', window, colourStim, vTargetCood);
            Screen('Flip', window);
            targetStart(i) = GetSecs;
            WaitSecs(stimPresT);
            Screen('Flip', window);
        end 
        
%--------------------------------------------------------------------------
% COLLECT RESPONSE
% 
% RTBox code adapted from RTBoxdemo.m
%--------------------------------------------------------------------------
        
        if useRTBox == 1
            WaitSecs(maxWaitT); 
            if isempty(t), 
                continue; 
            end % no response, nan in the data
            t = t - targetStart(i); %  response time
            if length(t) > 1 % more than 1 response
                ind = find(t>0,1); % use 1st proper rt if > 1 
                if isempty(ind) 
                    continue; 
                end  % no reasonable response, skip it
                t = t(ind);
            end
            RTs(i, 1) = t; % record the RT
        else 
            time0 = GetSecs;
            flag2 = 0; 
            while (GetSecs-time0 < time0 + maxWaitT && flag2 == 0)
                [keyIsDown, secs, keyCode] = KbCheck; %check keyboard
                if keyIsDown % if any keypress
                    if any(ismember(KbName(keyCode),KbName(responseKey)))
                        flag2 = 1; %
                        timeKeyPress(i) = GetSecs; % time for key press
                        RTs(i, 1) = timeKeyPress(i)-targetStart(i); %RT 
                    end
                end
            end
        end 
        % Stop playback
        PsychPortAudio('Stop', pahandle);
        WaitSecs(randi(500)/1000);  
    end 
    
%--------------------------------------------------------------------------
% CLOSING SCREEN 
%--------------------------------------------------------------------------
    
    thankYouText = 'Thank you!';
    height=RectHeight(Screen ('TextBounds', window, thankYouText));
    width=RectWidth(Screen ('TextBounds', window, thankYouText));
    Screen('DrawText', window, thankYouText, DisplayXSize/2 - width/2,... 
        DisplayYSize/2, white);
    Screen('Flip', window);
    WaitSecs (0.5);
    Screen('Flip', window);
    Screen('CloseAll');
    PsychPortAudio('Close', pahandle);
    ShowCursor;   
       
catch 
    sca; 
    disp('error'); 
    close all; 
end 

%% EXPERIMENT END
%--------------------------------------------------------------------------
% SORT RT DATA 
%--------------------------------------------------------------------------

resultsTable = [expTrialOrder, RTs];
    
aRTs = round(resultsTable(find(resultsTable(:, 1) == 1), 2)*1000);
vRTs = round(resultsTable(find(resultsTable(:, 1) == 2), 2)*1000);
avRTs = round(resultsTable(find(resultsTable(:, 1) == 3), 2)*1000);

% Saves your RT data 
save('RS_Data', 'resultsTable', 'aRTs', 'vRTs', 'avRTs');

%--------------------------------------------------------------------------
% DISPLAY MEANS
%--------------------------------------------------------------------------

disp('RESULTS'); 
disp(['Auditory Stimulus Mean RT: ' num2str(mean(aRTs)) 'ms']);
disp(['Visual Stimulus Mean RT: ' num2str(mean(vRTs)) 'ms']);
disp(['Redundant Stimulus Mean RT: ' num2str(mean(avRTs)) 'ms']);
disp(''); 

%--------------------------------------------------------------------------
% RUN RACE MODEL CODE
%
% Will require you have enough RT values to compute an effect. If not, the
% RaceModel code will give you an error message. If for any other reason 
% the code fails to run you'll get my error message below. 
%--------------------------------------------------------------------------

% variables to feed RaceModel 
p = 0.05:0.05:0.95; % probabilities 
getRacePlot = 1; % whether we want a plot

try 
    [Xp, Yp, Zp, Bp] = RaceModel(aRTs', vRTs', avRTs', p, getRacePlot);
catch 
    disp('Couldn''t run the Race Model Test script!'); 
end 


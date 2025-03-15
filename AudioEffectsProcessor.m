function AudioEffectsProcessor
    % Create GUI figure
    fig = uifigure('Name', 'Audio Effects Processor', 'Position', [100, 100, 800, 400]);
    
    % Load Audio Button
    btnLoad = uibutton(fig, 'Text', 'Load Audio', 'Position', [20, 350, 100, 30], 'ButtonPushedFcn', @loadAudio);
    
    % Effect Selection
    lblEffect = uilabel(fig, 'Text', 'Select Effect:', 'Position', [150, 355, 100, 20]);
    ddEffect = uidropdown(fig, 'Items', {'None', 'Reverb', 'Echo', 'Distortion'}, 'Position', [250, 350, 100, 30]);
    
    % Apply Effect Button
    btnApply = uibutton(fig, 'Text', 'Apply Effect', 'Position', [370, 350, 100, 30], 'ButtonPushedFcn', @applyEffect);
    
    % Play Button
    btnPlay = uibutton(fig, 'Text', 'Play', 'Position', [490, 350, 100, 30], 'ButtonPushedFcn', @playAudio);
    
    % Axes for waveform
    axWaveform = uiaxes(fig, 'Position', [50, 50, 700, 250]);
    title(axWaveform, 'Waveform');
    
    % Global Variables
    audioData = [];
    processedAudio = [];
    fs = 0;
    
    % Load Audio Function
    function loadAudio(~, ~)
        [file, path] = uigetfile({'*.wav'}, 'Select an Audio File');
        if file
            [audioData, fs] = audioread(fullfile(path, file));
            processedAudio = audioData; % Initialize processedAudio with the original audio
            plot(axWaveform, (1:length(audioData)) / fs, audioData);
            title(axWaveform, 'Loaded Audio Waveform');
        end
    end
    
    % Apply Effect Function
    function applyEffect(~, ~)
        if isempty(audioData)
            uialert(fig, 'Please load an audio file first.', 'Error');
            return;
        end
        
        effect = ddEffect.Value;
        processedAudio = audioData; % Default to original
        
        switch effect
            case 'Reverb'
                h = reverberator('PreDelay', 0.05, 'WetDryMix', 0.3); % Fixed PreDelay value
                processedAudio = h(audioData);
            case 'Echo'
                delay = 0.3; % 300 ms delay
                processedAudio = echoEffect(audioData, fs, delay);
            case 'Distortion'
                processedAudio = tanh(5 * audioData); % Non-linear distortion
        end
        
        % Plot the processed waveform
        plot(axWaveform, (1:length(processedAudio)) / fs, processedAudio);
        title(axWaveform, ['Waveform - ', effect]);
    end
    
    % Play Audio Function
    function playAudio(~, ~)
        if isempty(processedAudio)
            uialert(fig, 'No audio to play. Please load and process an audio file first.', 'Error');
            return;
        end
        sound(processedAudio, fs); % Play the processed audio
    end
    
    % Echo Effect Function
    function out = echoEffect(in, fs, delay)
        delaySamples = round(fs * delay);
        out = [in; zeros(delaySamples, 1)];
        out(delaySamples+1:end) = out(delaySamples+1:end) + 0.5 * in;
    end
end
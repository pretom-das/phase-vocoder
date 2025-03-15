function phase_vocoder_gui()
    fig = figure('Name', 'Phase Vocoder', 'NumberTitle', 'off', ...
        'Units', 'normalized', 'Position', [0, 0, 1, 1], 'MenuBar', 'none', 'ToolBar', 'none');

    original_audio = [];
    modified_audio = [];
    fs = 44100;
    undo_stack = {}; 
    audio_file_info = struct('FileName', '', 'FileSize', 0, 'NumChannels', 0, 'BitDepth', 0); % Store audio file info

    main_panel = uipanel('Parent', fig, 'Title', 'Phase Vocoder', ...
        'Units', 'normalized', 'Position', [0.02, 0.02, 0.96, 0.96], ...
        'BackgroundColor', [0.95, 0.95, 0.95]);

    % Load Audio button
    uicontrol('Parent', main_panel, 'Style', 'pushbutton', 'String', 'Load Audio', ...
        'Units', 'normalized', 'Position', [0.02, 0.9, 0.1, 0.05], 'Callback', @load_audio);

    % Time scaling controls
    uicontrol('Parent', main_panel, 'Style', 'text', 'String', 'Time Scaling (α)', ...
        'Units', 'normalized', 'Position', [0.02, 0.8, 0.1, 0.03], 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95, 0.95, 0.95]);
    alpha_slider = uicontrol('Parent', main_panel, 'Style', 'slider', ...
        'Units', 'normalized', 'Position', [0.02, 0.77, 0.1, 0.02], 'Min', 0.5, 'Max', 2, 'Value', 1);
    alpha_edit = uicontrol('Parent', main_panel, 'Style', 'edit', ...
        'String', '1.0', 'Units', 'normalized', 'Position', [0.02, 0.74, 0.1, 0.03]);

    % Pitch scaling controls
    uicontrol('Parent', main_panel, 'Style', 'text', 'String', 'Pitch Scaling (β)', ...
        'Units', 'normalized', 'Position', [0.02, 0.68, 0.1, 0.03], 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95, 0.95, 0.95]);
    beta_slider = uicontrol('Parent', main_panel, 'Style', 'slider', ...
        'Units', 'normalized', 'Position', [0.02, 0.65, 0.1, 0.02], 'Min', 0.5, 'Max', 2, 'Value', 1);
    beta_edit = uicontrol('Parent', main_panel, 'Style', 'edit', ...
        'String', '1.0', 'Units', 'normalized', 'Position', [0.02, 0.62, 0.1, 0.03]);

    % Preset options
    uicontrol('Parent', main_panel, 'Style', 'text', 'String', 'Presets', ...
        'Units', 'normalized', 'Position', [0.02, 0.56, 0.1, 0.03], 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95, 0.95, 0.95]);
    preset_menu = uicontrol('Parent', main_panel, 'Style', 'popupmenu', ...
        'String', {'Custom', 'Chipmunk (β=0.5)', 'Slow Motion (α=1.5)','Fast Forword (α=0.5)' ,'Robot (α=1, β=0.8)'}, ...
        'Units', 'normalized', 'Position', [0.02, 0.53, 0.1, 0.03], 'Callback', @apply_preset);

    % Effect options
    uicontrol('Parent', main_panel, 'Style', 'text', 'String', 'Effects', ...
        'Units', 'normalized', 'Position', [0.02, 0.47, 0.1, 0.03], 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95, 0.95, 0.95]);
    effect_menu = uicontrol('Parent', main_panel, 'Style', 'popupmenu', ...
        'String', {'None', 'Reverb', 'Echo', 'Distortion'}, ...
        'Units', 'normalized', 'Position', [0.02, 0.44, 0.1, 0.03]);

    % Process button
    uicontrol('Parent', main_panel, 'Style', 'pushbutton', 'String', 'Process', ...
        'Units', 'normalized', 'Position', [0.02, 0.38, 0.1, 0.05], 'Callback', @process_audio);

    % Undo button
    uicontrol('Parent', main_panel, 'Style', 'pushbutton', 'String', 'Undo', ...
        'Units', 'normalized', 'Position', [0.02, 0.32, 0.1, 0.05], 'Callback', @undo_processing);

    % Save button
    uicontrol('Parent', main_panel, 'Style', 'pushbutton', 'String', 'Save Output', ...
        'Units', 'normalized', 'Position', [0.02, 0.26, 0.1, 0.05], 'Callback', @save_audio);

    % Play buttons
    uicontrol('Parent', main_panel, 'Style', 'pushbutton', 'String', 'Play Original', ...
        'Units', 'normalized', 'Position', [0.02, 0.2, 0.1, 0.05], 'Callback', @play_original);
    uicontrol('Parent', main_panel, 'Style', 'pushbutton', 'String', 'Play Modified', ...
        'Units', 'normalized', 'Position', [0.02, 0.14, 0.1, 0.05], 'Callback', @play_modified);

    % Stop button
    uicontrol('Parent', main_panel, 'Style', 'pushbutton', 'String', 'Stop', ...
        'Units', 'normalized', 'Position', [0.02, 0.08, 0.1, 0.05], 'Callback', @stop_audio);

    % Progress bar
    progress_bar = uicontrol('Parent', main_panel, 'Style', 'text', 'String', 'Ready', ...
        'Units', 'normalized', 'Position', [0.02, 0.02, 0.1, 0.03], 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.95, 0.95, 0.95]);

    % Create axes for plots and additional information
    ax_original = axes('Parent', main_panel, 'Units', 'normalized', 'Position', [0.15, 0.55, 0.4, 0.4]);
    ax_modified = axes('Parent', main_panel, 'Units', 'normalized', 'Position', [0.6, 0.55, 0.4, 0.4]);
    ax_fft = axes('Parent', main_panel, 'Units', 'normalized', 'Position', [0.15, 0.1, 0.4, 0.35]);
    ax_info = uipanel('Parent', main_panel, 'Title', 'Audio Information', ...
        'Units', 'normalized', 'Position', [0.6, 0.1, 0.4, 0.35], ...
        'BackgroundColor', [0.95, 0.95, 0.95]);

    % Link slider and edit box callbacks
    alpha_slider.Callback = {@update_slider, alpha_edit};
    alpha_edit.Callback = {@update_edit, alpha_slider};
    beta_slider.Callback = {@update_slider, beta_edit};
    beta_edit.Callback = {@update_edit, beta_slider};

    % Callback functions
    function load_audio(~, ~)
        [file, path] = uigetfile({'*.wav;*.mp3;*.ogg;*.flac;*.au', 'Audio Files'});
        if file == 0
            return;
        end
        [x, fs] = audioread(fullfile(path, file));
        original_audio = mean(x, 2); % Convert to mono
        modified_audio = original_audio; % Initialize modified audio
        undo_stack = {}; % Clear undo stack

        % Get audio file information
        audio_file_info.FileName = file;
        audio_file_info.FileSize = dir(fullfile(path, file)).bytes / 1024; % Size in KB
        audio_file_info.NumChannels = size(x, 2);
        info = audioinfo(fullfile(path, file));
        % audio_file_info.BitDepth = info.BitsPerSample;

        % Update plots and info panel
        plot_audio(ax_original, original_audio, 'Original Signal');
        plot_audio(ax_modified, modified_audio, 'Modified Signal');
        plot_fft(ax_fft, original_audio, fs);
        update_info_panel(ax_info, original_audio, fs, audio_file_info);
        progress_bar.String = 'Audio Loaded';
    end

    function process_audio(~, ~)
        if isempty(original_audio)
            errordlg('Please load an audio file first.');
            return;
        end

        % Push current state to undo stack
        undo_stack{end+1} = modified_audio;

        % Get scaling factors
        alpha = alpha_slider.Value;
        beta = beta_slider.Value;

        % Phase vocoder parameters
        N = 1024;       % Window size
        Ha = N/4;       % Analysis hop size (25% overlap)

        % Time scaling
        progress_bar.String = 'Processing...';
        drawnow;
        y_time_scaled = phase_vocoder(modified_audio, alpha, N, Ha);

        % Pitch scaling using resampling
        [P, Q] = rat(beta, 0.0001);
        modified_audio = resample(y_time_scaled, P, Q);

        % Apply selected effect
        effect = effect_menu.String{effect_menu.Value};
        switch effect
            case 'Reverb'
                h = reverberator('PreDelay', 0.05, 'WetDryMix', 0.3); % Fixed PreDelay value
                modified_audio = h(modified_audio);
            case 'Echo'
                delay = 0.3; % 300 ms delay
                modified_audio = echoEffect(modified_audio, fs, delay);
            case 'Distortion'
                modified_audio = tanh(5 * modified_audio); % Non-linear distortion
        end

        % Plot modified signal and FFT
        plot_audio(ax_modified, modified_audio, 'Modified Signal');
        plot_fft(ax_fft, modified_audio, fs);
        update_info_panel(ax_info, modified_audio, fs, audio_file_info);
        progress_bar.String = 'Processing Complete';
    end

    function save_audio(~, ~)
        if isempty(modified_audio)
            errordlg('No modified audio to save.');
            return;
        end
        [file, path] = uiputfile({'*.wav', 'WAV File'}, 'Save Audio');
        if file == 0
            return;
        end
        audiowrite(fullfile(path, file), modified_audio, fs);
        progress_bar.String = 'Audio Saved';
    end

    function undo_processing(~, ~)
        if isempty(undo_stack)
            errordlg('No previous state to undo.');
            return;
        end
        modified_audio = undo_stack{end};
        undo_stack(end) = [];
        plot_audio(ax_modified, modified_audio, 'Modified Signal');
        plot_fft(ax_fft, modified_audio, fs);
        update_info_panel(ax_info, modified_audio, fs, audio_file_info);
        progress_bar.String = 'Undo Complete';
    end

    function apply_preset(src, ~)
        preset = src.String{src.Value};
        switch preset
            case 'Chipmunk (β=0.5)'
                beta_slider.Value = 0.5;
                beta_edit.String = '0.5';
            case 'Slow Motion (α=1.5)'
                alpha_slider.Value = 1.5;
                alpha_edit.String = '1.5';
            case 'Fast Forword (α=0.5)'
                alpha_slider.Value = 0.5;
                alpha_edit.String = '0.5';
            case 'Robot (α=1, β=0.8)'
                alpha_slider.Value = 1;
                alpha_edit.String = '1.0';
                beta_slider.Value = 0.8;
                beta_edit.String = '0.8';
            
        end
    end

    function play_original(~, ~)
        if ~isempty(original_audio)
            sound(original_audio, fs);
        end
    end

    function play_modified(~, ~)
        if ~isempty(modified_audio)
            sound(modified_audio, fs);
        end
    end

    function stop_audio(~, ~)
        % Stop audio playback
        clear sound;
        progress_bar.String = 'Playback Stopped';
    end

    function update_slider(src, ~, edit)
        value = src.Value;
        edit.String = num2str(value, '%.2f');
    end

    function update_edit(src, ~, slider)
        value = str2double(src.String);
        if isnan(value) || value < slider.Min || value > slider.Max
            errordlg('Invalid value');
            src.String = num2str(slider.Value, '%.2f');
            return;
        end
        slider.Value = value;
    end

    function plot_audio(ax, audio, title_str)
        plot(ax, audio);
        ax.Title.String = title_str;
        ax.XLim = [0, length(audio)];
    end

    function plot_fft(ax, audio, fs)
        L = length(audio);
        Y = fft(audio);
        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = fs*(0:(L/2))/L;
        plot(ax, f, P1);
        ax.Title.String = 'FFT of Signal';
        ax.XLabel.String = 'Frequency (Hz)';
        ax.YLabel.String = 'Magnitude';
    end

    function update_info_panel(panel, audio, fs, audio_info)
        % Clear previous content
        delete(get(panel, 'Children'));

        % Display audio information
        info_str = { ...
            sprintf('File Name: %s', audio_info.FileName), ...
            sprintf('Sampling Rate: %d Hz', fs), ...
            sprintf('Duration: %.2f s', length(audio)/fs), ...
            sprintf('Number of Channels: %d', audio_info.NumChannels), ...
            sprintf('Bit Depth: %d bits', audio_info.BitDepth), ...
            sprintf('File Size: %.2f KB', audio_info.FileSize) ...
        };

        % Add text controls for each piece of information
        for i = 1:length(info_str)
            uicontrol('Parent', panel, 'Style', 'text', 'String', info_str{i}, ...
                'Units', 'normalized', 'Position', [0.05, 0.9 - 0.1*i, 0.9, 0.1], ...
                'HorizontalAlignment', 'left', 'BackgroundColor', [0.95, 0.95, 0.95]);
        end
    end
end

% Phase Vocoder Function
function y = phase_vocoder(x, alpha, N, Ha)
 Hs = round(Ha * alpha); % Synthesis hop size
    w = hann(N, 'periodic'); % Window function

    % STFT parameters
    L = length(x);
    num_frames = floor((L - N) / Ha) + 1;

    % Pad input signal
    x_padded = [x; zeros(N + Ha*num_frames - L, 1)];

    % Initialize STFT
    X = zeros(N, num_frames);
    for t = 1:num_frames
        frame = x_padded((t-1)*Ha + 1 : (t-1)*Ha + N) .* w;
        X(:, t) = fft(frame);
    end

    % Phase processing
    X_synth = zeros(size(X));
    prev_phase = angle(X(:, 1));
    X_synth(:, 1) = abs(X(:, 1)) .* exp(1i * prev_phase);

    for t = 2:num_frames
        curr_phase = angle(X(:, t));
        delta_phi = curr_phase - prev_phase;
        delta_phi = mod(delta_phi + pi, 2*pi) - pi;

        % Calculate frequency deviation
        omega = delta_phi / Ha;

        % Update phase
        synth_phase = prev_phase + omega * Hs;
        X_synth(:, t) = abs(X(:, t)) .* exp(1i * synth_phase);

        prev_phase = curr_phase;
    end

    % ISTFT
    y = zeros(N + (num_frames-1)*Hs, 1);
    sum_w = zeros(size(y));

    for t = 1:num_frames
        frame = real(ifft(X_synth(:, t)));
        start_idx = (t-1)*Hs + 1;
        end_idx = start_idx + N - 1;
        y(start_idx:end_idx) = y(start_idx:end_idx) + frame .* w;
        sum_w(start_idx:end_idx) = sum_w(start_idx:end_idx) + w.^2;
    end

    % Normalize output
    y = y ./ (sum_w + eps);
end

% Echo Effect Function
function y = echoEffect(x, fs, delay)
    delay_samples = round(delay * fs); % Convert delay to samples
    y = zeros(length(x) + delay_samples, 1);
    y(1:length(x)) = x;
    y(delay_samples + 1:end) = y(delay_samples + 1:end) + 0.5 * x; % Add echo
    y = y(1:length(x)); % Truncate to original length
end
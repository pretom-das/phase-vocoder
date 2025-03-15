# Phase Vocoder Audio Processing GUI

## Description
This repository contains the implementation of a **Phase Vocoder** audio processing system, featuring a **Graphical User Interface (GUI)** built with MATLAB. The Phase Vocoder allows for **time-stretching**, **pitch-shifting**, and **spectral manipulation** of audio signals. The GUI enables users to interact with these audio effects in real-time, providing **FFT spectrum visualization** for better insight into the audio manipulation.

Key Features:
- Real-time **FFT Spectrum Visualization**.
- **Time-stretching** and **Pitch-shifting** of audio.
- Interactive **GUI** for audio manipulation.
- Real-time **audio playback** with adjustable parameters.
- **FFT spectrum** display for real-time frequency content analysis.

## Installation

To run the Phase Vocoder Audio Processing GUI, follow the instructions below:

1. Clone the repository to your local machine:

    ```bash
    git clone https://github.com/yourusername/phase-vocoder-gui.git
    ```

2. Open MATLAB and navigate to the cloned repository directory:

    ```bash
    cd path/to/phase-vocoder-gui
    ```

3. Ensure that all required files are in the MATLAB path. Run the `PhaseVocoder_GUI.m` file to launch the GUI:

    ```matlab
    PhaseVocoder_GUI
    ```

4. **Audio files** can be loaded directly from the GUI for processing.

## Usage

Once the GUI is launched:

- **Load an audio file**: Use the "Load Audio" button to select an audio file from your computer.
- **Adjust parameters**: The GUI provides sliders for time-stretching and pitch-shifting. Adjust these sliders to modify the audio playback.
- **Visual Feedback**: The **FFT spectrum** will be displayed in real-time, showing how the frequency content of the audio evolves during processing.
- **Play Audio**: Press the "Play" button to hear the audio with the applied effects.

## Example Workflow

1. Load an audio file (e.g., a WAV or MP3 file).
2. Use the time-stretching and pitch-shifting sliders to modify the playback.
3. Observe the **FFT spectrum** plot for changes in frequency content.
4. Listen to the processed audio in real-time.

## Code Overview

### Main Components:
- **GUI Interface**: The interface includes buttons and sliders for controlling the audio effects.
- **FFT Visualization**: A dynamic plot that displays the **FFT spectrum** of the loaded audio.
- **Audio Processing**: The core Phase Vocoder algorithm for **time-stretching** and **pitch-shifting**.

### Key Files:
- `PhaseVocoder_GUI.m`: Main GUI file that handles user interaction.
- `plot_fft.m`: Function for plotting the FFT spectrum.
- `time_stretch.m`: Function for time-stretching the audio.
- `pitch_shift.m`: Function for pitch-shifting the audio.
- `audio_processing.m`: Core signal processing functions for Phase Vocoder.

## Contributing

If you would like to contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make the necessary changes.
4. Commit your changes and push them to your fork.
5. Open a pull request with a detailed explanation of your changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The Phase Vocoder technique was originally introduced by **Flanagan and Golden** in the 1960s for high-quality time-stretching and pitch-shifting.
- MATLAB for its powerful signal processing capabilities.
- [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/) for various signal processing tools.

## Contact

If you have any questions or suggestions, feel free to open an issue or reach out via email.


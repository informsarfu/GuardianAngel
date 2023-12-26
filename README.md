# Health Monitoring Application

## Overview

The Health Monitoring Application is a comprehensive mobile application designed to help users track their health and well-being. It includes features such as symptom recording, vital sign measurements (heart rate and respiratory rate), and a transportation safety component for real-time traffic details and collision avoidance.

## Features

1. **Symptom Recording and Database Management:**
   - Record daily symptoms.
   - Store data in a structured SQLite database.

2. **Heart Rate Measurement:**
   - Utilizes the mobile camera and flashlight for video recording.
   - Calculates heart rate based on red blood pixel analysis.

3. **Respiratory Rate Measurement:**
   - Uses the accelerometer in the mobile phone.
   - Measures variations when the phone is placed on the chest.

4. **Google's Routes API Integration:**
   - Obtain traffic details between source and destination locations.
   - Determine road conditions for route planning.

5. **Collision Avoidance System:**
   - Assess road conditions using traffic details.
   - Implement autonomous braking and human intervention as needed.

## Getting Started

### Prerequisites

- Android Studio installed
- Google API key for Google's Routes API (instructions for obtaining [here](https://developers.google.com/maps/documentation/directions/get-api-key))

### Installation

1. Clone the repository:

   ```bash
   [git clone https://github.com/informsarfu/Health-Monitoring-Application.git](https://github.com/informsarfu/Health-Monitoring-Application.git)

2. Open the project in Android Studio.
3. Add your Google API key to the appropriate configuration file.

### Usage
1. Build and run the application on an Android device or emulator.
2. Record symptoms, measure heart rate, and use other features as needed.

### Contributing
We welcome contributions! If you have suggestions, bug reports, or want to contribute to the project, please follow our Contribution Guidelines.

### License
This project is licensed under the 

### Acknowledgments
Thanks to Google for providing the Routes API.
Inspiration for health monitoring features from various open-source projects.

### Contact
For any inquiries or support, please contact [informsarfu@email.com].


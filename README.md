# Peblo AI Story Buddy

## Overview

Peblo AI Story Buddy is a Flutter application built for the Peblo Flutter Developer Internship Challenge.

The application narrates a short story using Text-to-Speech and then presents an interactive quiz generated from JSON data. It provides engaging feedback through animations, confetti celebrations, and a child-friendly interface.

## Features

* Text-to-Speech story narration using flutter_tts
* Dynamic quiz rendering from JSON data
* Quiz appears automatically after narration completes
* Wrong answer feedback with shake animation and visual indication
* Confetti celebration for correct answers
* Kid-friendly UI with vibrant colors
* Provider-based state management
* Lightweight and optimized for mid-range Android devices

## Framework Choice

Flutter was chosen because it enables cross-platform development from a single codebase while providing smooth animations, fast UI rendering, and excellent support for mobile applications.

## State Management

Provider is used to manage:

* Story narration state
* Loading state
* Quiz visibility state
* Success state
* User interaction feedback

This keeps the UI reactive while minimizing unnecessary widget rebuilds.

## Data-Driven Quiz Rendering

The quiz is rendered directly from a JSON object.

The UI does not depend on hardcoded questions or options. It automatically adapts if future JSON data contains a different question or a different number of answer choices.

Example:

{
"question": "What colour was Pip the Robot's lost gear?",
"options": ["Red", "Green", "Blue", "Yellow"],
"answer": "Blue"
}

## Audio Loading and Failure Handling

Text-to-Speech is implemented using flutter_tts.

The application:

* Shows loading/preparation state before narration
* Handles narration completion events
* Reveals the quiz only after narration finishes
* Prevents UI blocking during playback

## Transition Between Audio and Quiz

The quiz remains hidden while narration is active.

When the TTS completion callback is triggered, the application updates state through Provider and smoothly reveals the quiz section.

## Caching Approach

Since device-native Text-to-Speech is used, audio files are generated locally and no remote audio downloads are required.

For future API-based narration (e.g., ElevenLabs), generated audio files could be cached locally using path_provider and local storage.

## Performance Optimizations

* Provider limits unnecessary rebuilds
* Lightweight widget tree
* Efficient animations
* Confetti triggered only on success
* Optimized for mid-range Android devices (~3GB RAM)

## Performance Profiling

Flutter Performance Overlay and DevTools were used to verify smooth UI behavior.

Animations remained responsive and maintained smooth rendering during quiz interactions and celebration effects.

## AI Usage and Judgment

AI assistance was used for guidance on Flutter architecture, Provider integration, debugging, and animation implementation.

One suggestion that was modified:

A more complex state-management architecture was initially considered, but Provider was chosen because it was simpler, lightweight, and more appropriate for the scope of this application.

## Project Structure

lib/
├── main.dart
├── providers/
├── models/
├── widgets/
└── screens/

## Demo Flow

1. Tap "Read Story"
2. Story narration begins
3. Quiz appears after narration completes
4. Wrong answer triggers feedback animation
5. Correct answer triggers celebration and success state

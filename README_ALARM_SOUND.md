# Alarm Sound Setup Guide

## 📁 File Location
Place your alarm sound file here: `android/app/src/main/res/raw/alarm_sound.mp3`

## 🔧 Steps to Add Alarm Sound:

1. **Find or Create Alarm Sound**
   - Download a short MP3 alarm sound (3-5 seconds recommended)
   - Or record your own alarm tone
   - Keep file size under 1MB for optimal performance

2. **File Requirements**
   - **Name**: Must be exactly `alarm_sound.mp3`
   - **Format**: MP3
   - **Duration**: 3-5 seconds (it will repeat automatically)
   - **Quality**: Clear and audible alarm tone

3. **Installation**
   - Copy your `alarm_sound.mp3` file
   - Paste it in: `android/app/src/main/res/raw/`
   - Replace this instruction file

## 🎵 Recommended Alarm Sounds:
- Classic beep-beep-beep tone
- Digital alarm clock sound  
- Siren or buzzer sound
- Bell ringing
- Electronic alarm tone

## ✅ How It Works:
Once you add the `alarm_sound.mp3` file:
1. **Scheduled alarms will automatically ring at the set time**
2. **Sound plays repeatedly for 10 seconds** 
3. **Works even when app is minimized or closed**
4. **User can stop by tapping notification or it auto-stops**
5. **Includes vibration pattern during alarm**

## 🚨 Current Status:
- ❌ No alarm sound file (using system default)
- ➡️ Add `alarm_sound.mp3` to enable custom alarm sound

## 📱 For iOS (Optional):
Also add `alarm_sound.aiff` in the iOS app bundle for iOS devices.

---
**Note**: The alarm system is fully functional with vibration. Adding the sound file will enhance the alarm with your custom audio.
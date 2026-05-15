# Privacy Policy

**Last updated:** 15th May 2026

## Introduction

A Tour of Go ("we", "our", or "the app") respects your privacy. This Privacy Policy explains how your information is handled when you use the app.

***

## Information We Collect

A Tour of Go is designed as a **local-first application**. It is a mobile reader for the official Go tour and a small playground for running Go code.

### We DO NOT collect or store:
- Personal information (name, email, phone number)
- Account credentials of any kind
- Location data
- Contacts or media files
- Usage analytics or crash reports

***

## Local Data Storage

All app state stays on your device, including:
- Your current chapter and lesson position
- Lessons you have marked as completed
- Your theme, font size, and "wrap code lines" preference
- The cached copy of the tour content

This data is stored locally using `SharedPreferences`. We do **not** transmit, sync, or store any of it on a remote server.

***

## Network Use

The app talks to a small set of services owned by third parties, only when needed.

### Tour content
On first launch, and whenever you tap "Refresh", the app fetches the official tour from `https://go.dev/tour/lesson/` and caches it locally. The request includes no identifiers tied to you.

### Running code (Sandbox and lesson Run buttons)
When you tap **Run** on a lesson sample or in the Sandbox, the app sends the Go source from the editor to `https://go.dev/_/compile`, the same service the official Go Playground uses. The Go Playground compiles and executes the code on its servers and returns the output. Anything you paste, type, or save in the editor before tapping Run leaves your device only at that moment. Their usage of submitted code is governed by Google's policies for go.dev.

### Fonts
UI fonts are loaded at runtime via the `google_fonts` package from Google's Fonts CDN. No identifying request data is added by the app.

### External links
Lessons may contain links to documentation. Tapping them opens your device's default browser; the app does not proxy or track those visits.

***

## Third-Party Services

The only third-party endpoints the app contacts are:
- `go.dev` (lesson content and the code compile endpoint), operated by Google.
- `fonts.gstatic.com` / `fonts.googleapis.com` (UI fonts), operated by Google.

We do not embed analytics SDKs, ads SDKs, or crash reporters.

***

## Data Security

Since all your state is stored locally:
- You are responsible for securing your device.
- We recommend enabling device-level security (PIN, fingerprint, etc.).

***

## Data Deletion

You can delete your data by:
- Clearing app data from device settings.
- Uninstalling the app.

There is nothing for us to delete remotely because we never had it.

***

## Children's Privacy

The app does not knowingly collect any data from anyone, including children.

***

## Changes to This Policy

We may update this Privacy Policy in the future. Any changes will be reflected in this document.

***

## Contact

If you have any questions, you can contact:
Gautam Rajeev Singh

***

## Summary

- No cloud storage of your app state
- No analytics, no tracking, no ads
- Network calls are limited to fetching the Go tour content, sending code to the Go Playground when you tap Run, and loading UI fonts
- Full control stays with the user

# VS Code Configuration

## Setup

1. Copy `settings.json.example` to `settings.json`
2. Adjust settings based on your preferences

## Common Issues

### Java/Gradle Errors in VS Code

If you see errors like:
- "Project configurator 'org.eclipse.buildship.configurators.base' failed"
- "Unbound classpath container: 'JRE System Library'"

**Solution:** Add this to your `settings.json`:
```json
{
    "java.enabled": false
}
```

This disables Java extension for Flutter projects (not needed for Flutter development).

### Kotlin Daemon Issues

If you experience Kotlin daemon crashes during build:

1. Copy `android/gradle.properties.local.example` to `android/gradle.properties.local`
2. This file is gitignored and won't affect other developers

### Note

- `settings.json` is gitignored (personal preferences)
- `android/gradle.properties.local` is gitignored (local build config)
- Use example files as templates
- Gradle build works regardless of VS Code settings

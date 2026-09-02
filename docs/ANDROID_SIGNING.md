# Android signing

Speed Math requires an explicit production release keystore. Release builds never fall back to the debug certificate.

## Keep private

Keep `android/key.properties`, the production `.jks` or `.keystore`, passwords, and the key alias on secure personal storage. These files are ignored by Git. Never commit them or place them in source code.

## Local release setup

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill in the private signing values.
3. Keep the production keystore outside the repository when practical.
4. Run `flutter build appbundle --release`.

Gradle verifies that the configured keystore exists before a release task can run.

## Fingerprints

Generate fingerprints locally:

```bash
keytool -list -v -keystore /path/to/speed-math-release.jks -alias speed_math_release
```

Only the resulting SHA-1 and SHA-256 fingerprints should be entered into Firebase or Google configuration. Do not share the keystore.

Firebase requires the Android SHA-1 certificate fingerprint for Google Sign-In. Google Play App Signing has its own production certificate; register that fingerprint as required after Play App Signing is enabled.

## CI

GitHub Actions creates a short-lived CI-only signing keystore during release packaging validation. It is different from the production signing identity and is not stored in the repository.

This keeps the real production signing identity under the owner's control while allowing CI to validate release packaging.

# Speed Math Admin

The admin app is intentionally a separate Flutter package so Firebase SDKs do **not** increase the end-user APK.

## Firebase setup

1. Use Firebase project `speed-math-app-1` or create a dedicated production project.
2. Enable Email/Password Authentication.
3. Create a Cloud Firestore database in Native/Standard mode.
4. Deploy `../firebase/firestore.rules`.
5. Create the first administrator in Firebase Authentication.
6. In Firestore, manually create `admins/<AUTH_UID>` with a simple field such as `role: admin`.
7. Configure the admin app with the Firebase web configuration values using Dart defines:

```text
FIREBASE_API_KEY
FIREBASE_APP_ID
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_PROJECT_ID=speed-math-app-1
```

Run the admin console with your preferred Flutter target, for example web. The app uses Firebase Authentication for sign-in and Firestore for draft/publish workflows.

## Content model

- `draftTopics/<topicId>` — editable admin draft.
- `publishedContent/current` — the single public, published curriculum snapshot consumed by the user app.
- `admins/<uid>` — administrator allow-list.

The user app reads only `publishedContent/current` and falls back to the bundled curriculum when offline or when the remote document is unavailable.

## Publishing workflow

`Bundled seed → Draft → Edit → Save → Publish → User sync → Local cache`

The user application never receives Firebase Auth or Firestore SDKs. It uses the existing HTTP dependency for the lightweight published-content read, preserving the tiny-app requirement.

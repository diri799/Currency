# Supabase Setup Guide for CurrenSee

This guide will help you set up Supabase as the backend for your CurrenSee app, replacing Firebase.

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: `currensee-app` (or your preferred name)
   - **Database Password**: Generate a strong password
   - **Region**: Choose the closest region to your users
5. Click "Create new project"
6. Wait for the project to be created (usually 2-3 minutes)

## 2. Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://your-project.supabase.co`)
   - **Anon/Public Key** (starts with `eyJ...`)

## 3. Update Your Flutter App Configuration

1. Open `lib/core/supabase/supabase_config.dart`
2. Replace the placeholder values:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';
```

## 4. Set Up the Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Copy the contents of `lib/core/supabase/database_schema.sql`
3. Paste it into the SQL editor and click "Run"

This will create all the necessary tables, indexes, and security policies.

## 5. Configure Authentication Providers (Optional)

### Google Sign-In
1. Go to **Authentication** → **Providers**
2. Enable **Google**
3. Add your Google OAuth credentials:
   - **Client ID**: From Google Cloud Console
   - **Client Secret**: From Google Cloud Console
4. Add your app's redirect URL to Google OAuth settings

### Apple Sign-In
1. Go to **Authentication** → **Providers**
2. Enable **Apple**
3. Add your Apple OAuth credentials:
   - **Client ID**: From Apple Developer Console
   - **Client Secret**: From Apple Developer Console

## 6. Set Up OneSignal for Push Notifications (Optional)

1. Go to [onesignal.com](https://onesignal.com) and create an account
2. Create a new app
3. Get your **App ID**
4. Update `lib/core/notifications/notification_service.dart`:

```dart
OneSignal.initialize('your-onesignal-app-id');
```

## 7. Configure Row Level Security (RLS)

The database schema already includes RLS policies, but you can review them in:
- **Database** → **Tables** → Select a table → **RLS** tab

## 8. Test Your Setup

1. Run your Flutter app: `flutter run`
2. Try creating an account
3. Test currency conversion
4. Check that data appears in your Supabase dashboard

## 9. Environment Variables (Production)

For production, consider using environment variables instead of hardcoding credentials:

```dart
static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

Then run with:
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## 10. Database Backups

1. Go to **Settings** → **Database**
2. Enable **Point-in-time Recovery** for automatic backups
3. Set up manual backups if needed

## 11. Monitoring and Analytics

1. Go to **Reports** to monitor your app's performance
2. Check **Logs** for any issues
3. Monitor **Database** usage and performance

## Troubleshooting

### Common Issues:

1. **"Invalid API key"**: Check that you copied the correct anon key
2. **"RLS policy violation"**: Ensure RLS policies are set up correctly
3. **"Connection failed"**: Check your internet connection and Supabase status
4. **"Google/Apple sign-in not working"**: Verify OAuth credentials and redirect URLs

### Getting Help:

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Discord](https://discord.supabase.com)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)

## Migration from Firebase

If you're migrating from Firebase, the following features have been replaced:

- **Firebase Auth** → **Supabase Auth**
- **Cloud Firestore** → **Supabase Database (PostgreSQL)**
- **Firebase Storage** → **Supabase Storage**
- **Firebase Functions** → **Supabase Edge Functions**
- **Firebase Messaging** → **OneSignal** (or Supabase + webhooks)

The app now uses Supabase for all backend functionality while maintaining the same user experience.

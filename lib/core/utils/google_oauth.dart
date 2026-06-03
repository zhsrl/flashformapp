const googleOAuthClientId =
    '271304709167-vk1omt2b12ql3nvk71p6bpa6l0r9mqqm.apps.googleusercontent.com';

const googleOAuthScopes = [
  'openid',
  'email',
  'profile',
  'https://www.googleapis.com/auth/spreadsheets',
  'https://www.googleapis.com/auth/drive.readonly',
];

String googleOAuthRedirectUri() {
  return '${Uri.base.origin}/oauth/google';
}

Uri buildGoogleOAuthUri({required String formId}) {
  return Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
    'client_id': googleOAuthClientId,
    'redirect_uri': googleOAuthRedirectUri(),
    'response_type': 'code',
    'scope': googleOAuthScopes.join(' '),
    'access_type': 'offline',
    'prompt': 'consent',
    'state': formId,
  });
}

// OpenAPI 3 spec, served at /api/docs (UI) and /api/docs.json (raw).
// Keep in sync with routes/*.js. All responses use the envelope { success, message, data }.
// Money is whole paise (₹250.50 = 25050); days are "YYYY-MM-DD" strings.

const envelope = (dataSchema, message) => ({
  type: 'object',
  required: ['success', 'message', 'data'],
  properties: {
    success: { type: 'boolean', example: true },
    message: { type: 'string', example: message || 'OK' },
    data: dataSchema,
  },
});

const nullData = { type: 'object', nullable: true, example: null };

const jsonBody = (schema, example) => ({
  required: true,
  content: { 'application/json': { schema, ...(example && { example }) } },
});

// Swagger UI shows `data: {}` for a null schema example, so null data gets an explicit media-type example.
const okResponse = (description, dataSchema, message) => ({
  description,
  content: {
    'application/json': {
      schema: envelope(dataSchema, message),
      ...(dataSchema === nullData && { example: { success: true, message, data: null } }),
    },
  },
});

const err = (description, message) => ({
  description,
  content: {
    'application/json': {
      schema: { $ref: '#/components/schemas/Error' },
      example: { success: false, message, data: null },
    },
  },
});

const emailProp = { type: 'string', format: 'email', example: 'user@example.com' };
const codeProp = { type: 'string', pattern: '^\\d{6}$', example: '482913' };
const passwordProp = { type: 'string', minLength: 8, example: 'secret123' };
const auth = [{ bearerAuth: [] }];
const serverErr = err('Unhandled server error', 'Internal server error');
const unauthorized = err('Missing, invalid or expired token', 'Not authorized');

const devCodeProp = {
  type: 'string',
  description:
    'Only present when the server could not send a real email (SMTP not configured) and is not in production. Never returned once email sending works.',
  example: '482913',
};

const sessionData = {
  type: 'object',
  properties: {
    token: { type: 'string', description: 'JWT, valid 30 days. Send as `Authorization: Bearer <token>`.', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' },
    user: { $ref: '#/components/schemas/User' },
  },
};

const userExample = {
  _id: '6710a1b2c3d4e5f607182930',
  email: 'user@example.com',
  isVerified: true,
  name: 'Asha',
  photoUrl: null,
  onboardingComplete: true,
  monthlyBudget: 3000000,
  categoryLimits: { food: 800000, travel: 400000 },
  hasExampleData: false,
  createdAt: '2026-10-09T09:00:00.000Z',
  updatedAt: '2026-10-09T09:05:00.000Z',
};

module.exports = {
  openapi: '3.0.3',
  info: {
    title: 'Budgie API',
    version: '1.0.0',
    description:
      'Every response uses the envelope `{ success, message, data }`. Errors return `success: false` and `data: null`.\n\n' +
      '**Money** is whole paise (₹250.50 = `25050`). **Days** are `"YYYY-MM-DD"` strings.\n\n' +
      '**Auth:** log in (or verify your email) to get a token, click **Authorize** and paste it. Endpoints with a lock icon need it.\n\n' +
      '**Codes:** 6 digits, valid 15 minutes, 5 wrong tries, 30 seconds between requests for a new one.',
  },
  servers: [
    { url: 'https://budgetbackend-mu.vercel.app', description: 'Production' },
    { url: 'http://localhost:3000', description: 'Local' },
  ],
  tags: [{ name: 'Health' }, { name: 'Auth' }, { name: 'Users' }],
  components: {
    securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' } },
    schemas: {
      Error: {
        type: 'object',
        properties: {
          success: { type: 'boolean', example: false },
          message: { type: 'string', example: 'Something went wrong' },
          data: { type: 'object', nullable: true, example: null },
        },
      },
      User: {
        type: 'object',
        example: userExample,
        properties: {
          _id: { type: 'string' },
          email: emailProp,
          isVerified: { type: 'boolean' },
          googleId: { type: 'string', description: 'Present when a Google account is linked.' },
          name: { type: 'string', maxLength: 24, example: 'Asha' },
          photoUrl: { type: 'string', nullable: true },
          onboardingComplete: {
            type: 'boolean',
            description: 'Becomes true once a name and a monthly budget above 0 are saved. The app uses it to skip setup.',
          },
          monthlyBudget: { type: 'integer', minimum: 0, description: 'Paise.', example: 3000000 },
          categoryLimits: {
            type: 'object',
            additionalProperties: { type: 'integer', minimum: 0 },
            description: 'Paise per category key (lowercase letters).',
            example: { food: 800000, travel: 400000 },
          },
          hasExampleData: { type: 'boolean' },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
        },
      },
    },
  },
  paths: {
    '/api/health': {
      get: {
        tags: ['Health'],
        summary: 'Server health check',
        responses: {
          200: {
            description: 'Server is up',
            content: { 'application/json': { example: { status: 'ok' } } },
          },
        },
      },
    },

    '/api/auth/signup': {
      post: {
        tags: ['Auth'],
        summary: 'Create an account and email a verification code',
        description:
          'Creates an unverified user (or restarts an unverified one) and emails a 6-digit code. The user cannot log in until `/auth/verify-email` succeeds.',
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['email', 'password'],
            properties: { email: emailProp, password: passwordProp },
          },
          { email: 'user@example.com', password: 'secret123' },
        ),
        responses: {
          201: okResponse(
            'Code sent',
            { type: 'object', properties: { email: emailProp, devCode: devCodeProp } },
            'Verification code sent',
          ),
          400: err('Invalid email or password shorter than 8 characters', 'Password must be at least 8 characters'),
          409: err('A verified account already uses this email', 'Email already registered'),
          429: err('Asked for a new code less than 30 seconds ago', 'Wait 30 seconds before requesting another code'),
          500: serverErr,
        },
      },
    },

    '/api/auth/verify-email': {
      post: {
        tags: ['Auth'],
        summary: 'Verify the email with the 6-digit code',
        description: 'On success the user is logged in and a token is returned.',
        requestBody: jsonBody(
          { type: 'object', required: ['email', 'code'], properties: { email: emailProp, code: codeProp } },
          { email: 'user@example.com', code: '482913' },
        ),
        responses: {
          200: okResponse('Email verified', sessionData, 'Email verified'),
          400: err('Wrong, expired or already used code, or email already verified', 'Incorrect code'),
          404: err('No account for this email', 'Account not found'),
          429: err('5 wrong codes. Request a new one', 'Too many wrong codes. Request a new one'),
          500: serverErr,
        },
      },
    },

    '/api/auth/resend-code': {
      post: {
        tags: ['Auth'],
        summary: 'Send a new verification code',
        requestBody: jsonBody(
          { type: 'object', required: ['email'], properties: { email: emailProp } },
          { email: 'user@example.com' },
        ),
        responses: {
          200: okResponse('Code sent', { type: 'object', properties: { devCode: devCodeProp } }, 'Verification code sent'),
          404: err('No pending verification for this email', 'No pending verification for this email'),
          429: err('Asked less than 30 seconds ago', 'Wait 30 seconds before requesting another code'),
          500: serverErr,
        },
      },
    },

    '/api/auth/login': {
      post: {
        tags: ['Auth'],
        summary: 'Log in with email and password',
        requestBody: jsonBody(
          { type: 'object', required: ['email', 'password'], properties: { email: emailProp, password: { type: 'string', example: 'secret123' } } },
          { email: 'user@example.com', password: 'secret123' },
        ),
        responses: {
          200: okResponse('Logged in', sessionData, 'Logged in'),
          401: err('Wrong email or password', 'Invalid email or password'),
          403: err('Correct password but the email is not verified. Call `/auth/resend-code`, then `/auth/verify-email`.', 'Email not verified'),
          500: serverErr,
        },
      },
    },

    '/api/auth/google': {
      post: {
        tags: ['Auth'],
        summary: 'Log in or sign up with a Google ID token',
        description:
          'The app signs in with Google and sends the Google **ID token** (not the access token). Google accounts are verified automatically.\n\n' +
          '`mode: "login"` fails with 404 when no account exists. `mode: "signup"` (default) creates the account if needed.',
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['idToken'],
            properties: {
              idToken: { type: 'string', example: 'eyJhbGciOiJSUzI1NiIs...' },
              mode: { type: 'string', enum: ['login', 'signup'], default: 'signup' },
            },
          },
          { idToken: 'eyJhbGciOiJSUzI1NiIs...', mode: 'login' },
        ),
        responses: {
          200: okResponse(
            'Existing account logged in',
            {
              type: 'object',
              properties: { ...sessionData.properties, isNewUser: { type: 'boolean', example: false } },
            },
            'Logged in',
          ),
          201: okResponse(
            'New account created',
            {
              type: 'object',
              properties: { ...sessionData.properties, isNewUser: { type: 'boolean', example: true } },
            },
            'Account created',
          ),
          400: err('idToken missing', 'Google ID token is required'),
          401: err('Token invalid, expired or for another app', 'Google sign-in failed. Please try again.'),
          404: err('`mode: "login"` and no account for this Google email', 'No account found for this Google email. Please sign up first.'),
          409: err('The email is linked to a different Google account', 'This email is linked to a different Google account'),
          500: serverErr,
        },
      },
    },

    '/api/auth/forgot-password': {
      post: {
        tags: ['Auth'],
        summary: 'Email a password reset code',
        description: 'Always answers the same way, so it never reveals whether an email is registered.',
        requestBody: jsonBody(
          { type: 'object', required: ['email'], properties: { email: emailProp } },
          { email: 'user@example.com' },
        ),
        responses: {
          200: okResponse(
            'Request accepted',
            { type: 'object', properties: { devCode: devCodeProp } },
            'If the email is registered, a reset code was sent',
          ),
          400: err('Invalid email', 'Valid email is required'),
          500: serverErr,
        },
      },
    },

    '/api/auth/verify-reset-code': {
      post: {
        tags: ['Auth'],
        summary: 'Check a reset code without using it',
        requestBody: jsonBody(
          { type: 'object', required: ['email', 'code'], properties: { email: emailProp, code: codeProp } },
          { email: 'user@example.com', code: '482913' },
        ),
        responses: {
          200: okResponse('Code is valid', nullData, 'Code is valid'),
          400: err('Wrong or expired code', 'Incorrect code'),
          429: err('5 wrong codes', 'Too many wrong codes. Request a new one'),
          500: serverErr,
        },
      },
    },

    '/api/auth/reset-password': {
      post: {
        tags: ['Auth'],
        summary: 'Set a new password with the reset code',
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['email', 'code', 'newPassword'],
            properties: { email: emailProp, code: codeProp, newPassword: passwordProp },
          },
          { email: 'user@example.com', code: '482913', newPassword: 'newsecret123' },
        ),
        responses: {
          200: okResponse('Password updated', nullData, 'Password updated'),
          400: err('Wrong or expired code, or password shorter than 8 characters', 'Incorrect code'),
          429: err('5 wrong codes', 'Too many wrong codes. Request a new one'),
          500: serverErr,
        },
      },
    },

    '/api/auth/change-password': {
      post: {
        tags: ['Auth'],
        summary: 'Change the password while logged in',
        security: auth,
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['currentPassword', 'newPassword'],
            properties: { currentPassword: { type: 'string', example: 'secret123' }, newPassword: passwordProp },
          },
          { currentPassword: 'secret123', newPassword: 'newsecret123' },
        ),
        responses: {
          200: okResponse('Password changed', nullData, 'Password changed'),
          400: err('New password shorter than 8 characters', 'New password must be at least 8 characters'),
          401: err('Current password is wrong, or token missing/invalid', 'Current password is incorrect'),
          500: serverErr,
        },
      },
    },

    '/api/users/me': {
      get: {
        tags: ['Users'],
        summary: 'Get the logged-in user',
        description: 'Call this on app start to restore the session and read `onboardingComplete`.',
        security: auth,
        responses: {
          200: okResponse('Current user', { type: 'object', properties: { user: { $ref: '#/components/schemas/User' } } }, 'OK'),
          401: unauthorized,
          500: serverErr,
        },
      },
      patch: {
        tags: ['Users'],
        summary: 'Update profile, monthly budget and category limits',
        description:
          'Send only the fields to change. `categoryLimits` is merged key by key. `onboardingComplete` turns true once `name` is set and `monthlyBudget` is above 0.',
        security: auth,
        requestBody: jsonBody(
          {
            type: 'object',
            properties: {
              name: { type: 'string', maxLength: 24, example: 'Asha' },
              photoUrl: { type: 'string', nullable: true },
              monthlyBudget: { type: 'integer', minimum: 0, description: 'Paise.', example: 3000000 },
              categoryLimits: {
                type: 'object',
                additionalProperties: { type: 'integer', minimum: 0 },
                description: 'Paise per category key (lowercase letters only).',
                example: { food: 800000 },
              },
            },
          },
          { name: 'Asha', monthlyBudget: 3000000, categoryLimits: { food: 800000 } },
        ),
        responses: {
          200: okResponse('Profile updated', { type: 'object', properties: { user: { $ref: '#/components/schemas/User' } } }, 'Profile updated'),
          400: err('Invalid value (name too long, amount not a whole number, bad category key)', 'Invalid category key "Food1"'),
          401: unauthorized,
          500: serverErr,
        },
      },
      delete: {
        tags: ['Users'],
        summary: 'Delete the account',
        description: 'Permanently deletes the user. Their transactions, goals and imports are removed too once those exist.',
        security: auth,
        responses: {
          200: okResponse('Account deleted', nullData, 'Account deleted'),
          401: unauthorized,
          500: serverErr,
        },
      },
    },
  },
};


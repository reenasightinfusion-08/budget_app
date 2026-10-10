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

const devNote =
  ' `data` is always `null`. The one exception is local development without SMTP configured, where it is `{ devCode }` so you can still test.';

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

const multipartSmartAdd = {
  type: 'object',
  required: ['inputType', 'today'],
  properties: {
    inputType: { type: 'string', enum: ['image', 'pdf'], example: 'image' },
    file: { type: 'string', format: 'binary', description: 'The photo (jpeg, png, webp, heic) or PDF. Max 4 MB.' },
    today: { type: 'string', description: 'The user\'s local day, YYYY-MM-DD.', example: '2026-10-10' },
    tzOffsetMinutes: { type: 'integer', description: 'Minutes ahead of UTC (IST = 330).', example: 330 },
  },
};

module.exports = {
  openapi: '3.0.3',
  info: {
    title: 'Budgie API',
    version: '1.0.0',
    description:
      'Every response uses the envelope `{ success, message, data }`. Errors return `success: false` and `data: null`.\n\n' +
      '**`data` is `null` for anything that only acts** (send a code, reset or change a password, delete the account). It only carries a value when the caller needs one back: the session token and user from login, verify-email and Google, the user from `/users/me`, and lists.\n\n' +
      '**Money** is whole paise (₹250.50 = `25050`). **Days** are `"YYYY-MM-DD"` strings.\n\n' +
      '**Auth:** log in (or verify your email) to get a token, click **Authorize** and paste it. Endpoints with a lock icon need it.\n\n' +
      '**Codes:** 6 digits, valid 15 minutes, 5 wrong tries, 30 seconds between requests for a new one.',
  },
  servers: [
    { url: 'https://budgetbackend-mu.vercel.app', description: 'Production' },
    { url: 'http://localhost:3000', description: 'Local' },
  ],
  tags: [{ name: 'Health' }, { name: 'Auth' }, { name: 'Users' }, { name: 'Categories' }, { name: 'Transactions' }, { name: 'Goals' }, { name: 'Smart add' }],
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
      Category: {
        type: 'object',
        properties: {
          key: { type: 'string', description: 'Stored in transactions.category and users.categoryLimits.', example: 'food' },
          type: { type: 'string', enum: ['income', 'expense'], example: 'expense' },
          label: { type: 'string', example: 'Food' },
          icon: { type: 'string', description: 'Icon key the app maps to an icon.', example: 'food' },
          color: { type: 'string', example: '#E8913A' },
          sortOrder: { type: 'integer', example: 1 },
        },
      },
      Transaction: {
        type: 'object',
        properties: {
          _id: { type: 'string', example: '6abde240bc24b8213063b0e3' },
          type: { type: 'string', enum: ['income', 'expense'], example: 'expense' },
          amount: { type: 'integer', minimum: 1, description: 'Paise, always positive. `type` gives the direction.', example: 180000 },
          category: { type: 'string', description: 'A category `key` of the same type.', example: 'food' },
          note: { type: 'string', maxLength: 40, example: 'DMart Ready' },
          date: { type: 'string', description: 'The user\'s own calendar day.', example: '2026-10-03' },
          source: { type: 'string', enum: ['manual', 'text', 'voice', 'receipt', 'statement'], example: 'manual' },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      TransactionInput: {
        type: 'object',
        required: ['type', 'amount', 'category', 'date'],
        properties: {
          type: { type: 'string', enum: ['income', 'expense'], example: 'expense' },
          amount: { type: 'integer', minimum: 1, description: 'Whole paise (₹250.50 = 25050).', example: 180000 },
          category: { type: 'string', description: 'An active category key of the same type. See `GET /api/categories`.', example: 'food' },
          note: { type: 'string', maxLength: 40, example: 'DMart Ready' },
          date: { type: 'string', description: 'YYYY-MM-DD. Cannot be after the user\'s today.', example: '2026-10-03' },
        },
      },
      Goal: {
        type: 'object',
        properties: {
          _id: { type: 'string' },
          name: { type: 'string', maxLength: 28, example: 'Emergency fund' },
          icon: { type: 'string', enum: ['shield', 'phone', 'plane', 'house', 'gift', 'star'], example: 'shield' },
          targetAmount: { type: 'integer', minimum: 100, description: 'Paise.', example: 6000000 },
          targetMonth: { type: 'string', description: 'YYYY-MM', example: '2027-03' },
          savedAmount: { type: 'integer', description: 'Paise. Worked out by the server from `contributions`.', example: 3720000 },
          reachedAt: { type: 'string', format: 'date-time', nullable: true },
          contributions: {
            type: 'array',
            description: 'Oldest first. Negative amounts are Take out.',
            items: {
              type: 'object',
              properties: {
                amount: { type: 'integer', example: 1200000 },
                date: { type: 'string', example: '2026-06-02' },
              },
            },
          },
          createdAt: { type: 'string', format: 'date-time' },
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
          200: okResponse('Server is up', nullData, 'Server is running'),
        },
      },
    },

    '/api/auth/signup': {
      post: {
        tags: ['Auth'],
        summary: 'Create an account and email a verification code',
        description:
          'Creates an unverified user (or restarts an unverified one) and emails a 6-digit code. The user cannot log in until `/auth/verify-email` succeeds.' + devNote,
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['email', 'password'],
            properties: { email: emailProp, password: passwordProp },
          },
          { email: 'user@example.com', password: 'secret123' },
        ),
        responses: {
          201: okResponse('Code sent', nullData, 'Verification code sent'),
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
        description: 'Sends a fresh code. 30 seconds must pass since the last one.' + devNote,
        requestBody: jsonBody(
          { type: 'object', required: ['email'], properties: { email: emailProp } },
          { email: 'user@example.com' },
        ),
        responses: {
          200: okResponse('Code sent', nullData, 'Verification code sent'),
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
        description: 'Always answers the same way, so it never reveals whether an email is registered.' + devNote,
        requestBody: jsonBody(
          { type: 'object', required: ['email'], properties: { email: emailProp } },
          { email: 'user@example.com' },
        ),
        responses: {
          200: okResponse('Request accepted', nullData, 'If the email is registered, a reset code was sent'),
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
        description: 'Permanently deletes the user together with their transactions and Smart add runs and savings goals.',
        security: auth,
        responses: {
          200: okResponse('Account deleted', nullData, 'Account deleted'),
          401: unauthorized,
          500: serverErr,
        },
      },
    },

    '/api/categories': {
      get: {
        tags: ['Categories'],
        summary: 'List the shared categories',
        description:
          'Active categories for every user, income and expense, ordered by type then `sortOrder`. `other` exists once per type, so match on `type` + `key`. The app loads this once and caches it.',
        security: auth,
        responses: {
          200: okResponse(
            'Category list',
            { type: 'object', properties: { categories: { type: 'array', items: { $ref: '#/components/schemas/Category' } } } },
            'OK',
          ),
          401: unauthorized,
          500: serverErr,
        },
      },
    },

    '/api/transactions/summary': {
      get: {
        tags: ['Transactions'],
        summary: 'Everything Home, Insights and Budget need for one month',
        description:
          'The server returns raw totals and the app works out the rest (available to spend, per-day safe spend, pace, mood) using `monthlyBudget` and `categoryLimits` from `/users/me`. Nothing here is stored; it is computed from the transactions on every call. The app sends its own local month and today so the server never guesses the time zone.',
        security: auth,
        parameters: [
          { name: 'month', in: 'query', required: true, schema: { type: 'string', example: '2026-10' }, description: 'YYYY-MM' },
          { name: 'today', in: 'query', required: true, schema: { type: 'string', example: '2026-10-07' }, description: 'The user\'s local day, YYYY-MM-DD' },
        ],
        responses: {
          200: okResponse(
            'Month summary',
            {
              type: 'object',
              properties: {
                month: { type: 'string', example: '2026-10' },
                today: { type: 'string', example: '2026-10-07' },
                income: { type: 'integer', description: 'Paise earned this month.', example: 5200000 },
                expense: { type: 'integer', description: 'Paise spent this month.', example: 904000 },
                byCategory: {
                  type: 'array',
                  description: 'This month\'s totals per type and category. Feeds Top spend, Your plan and Where it went.',
                  items: {
                    type: 'object',
                    properties: {
                      type: { type: 'string', enum: ['income', 'expense'] },
                      category: { type: 'string', example: 'bills' },
                      total: { type: 'integer', example: 320000 },
                    },
                  },
                },
                weekStart: { type: 'string', description: 'Monday of the week that holds `today`.', example: '2026-10-05' },
                daily: {
                  type: 'array',
                  description: 'Spend per day (days with no spend are left out). Covers the month and the current week, so it feeds both the week bars and the pace chart.',
                  items: {
                    type: 'object',
                    properties: { date: { type: 'string', example: '2026-10-05' }, spent: { type: 'integer', example: 120000 } },
                  },
                },
                previousMonthSoFar: {
                  type: 'integer',
                  description: 'Spend last month over the same days that have passed this month, for "7% less than Sep".',
                  example: 977000,
                },
                months: {
                  type: 'array',
                  description: 'The last 6 months ending at `month`, oldest first, zeros filled in. Feeds Insights.',
                  items: {
                    type: 'object',
                    properties: {
                      month: { type: 'string', example: '2026-09' },
                      income: { type: 'integer', example: 5200000 },
                      expense: { type: 'integer', example: 2614000 },
                    },
                  },
                },
                recent: { type: 'array', description: 'The 4 newest entries.', items: { $ref: '#/components/schemas/Transaction' } },
                counts: {
                  type: 'object',
                  description: 'For the Profile screen.',
                  properties: { entries: { type: 'integer', example: 93 }, months: { type: 'integer', example: 6 } },
                },
              },
            },
            'OK',
          ),
          400: err('Missing or invalid month or today', 'month must be YYYY-MM'),
          401: unauthorized,
          500: serverErr,
        },
      },
    },

    '/api/transactions': {
      get: {
        tags: ['Transactions'],
        summary: 'List transactions, newest first (History)',
        description:
          'Newest day first, and within a day newest entry first. `q` searches notes and category labels, so "side" finds entries in the Side work category. Paging is by day: pass the returned `nextBefore` as `before` to get older days. A day is never split across pages, so a page can hold a few more than `limit`. `nextBefore` is `null` when there is nothing older.',
        security: auth,
        parameters: [
          { name: 'type', in: 'query', schema: { type: 'string', enum: ['income', 'expense'] }, description: 'Only money in or only money out.' },
          { name: 'q', in: 'query', schema: { type: 'string', example: 'fuel' }, description: 'Search notes and category labels.' },
          { name: 'before', in: 'query', schema: { type: 'string', example: '2026-10-05' }, description: 'Only days earlier than this one (YYYY-MM-DD).' },
          { name: 'limit', in: 'query', schema: { type: 'integer', default: 50, minimum: 1, maximum: 100 }, description: 'Approximate page size.' },
        ],
        responses: {
          200: okResponse(
            'Transactions',
            {
              type: 'object',
              properties: {
                transactions: { type: 'array', items: { $ref: '#/components/schemas/Transaction' } },
                nextBefore: { type: 'string', nullable: true, example: '2026-10-05' },
              },
            },
            'OK',
          ),
          400: err('Invalid type or before', 'type must be income or expense'),
          401: unauthorized,
          500: serverErr,
        },
      },
      post: {
        tags: ['Transactions'],
        summary: 'Add one spend or income (Add sheet)',
        description:
          'Saves one entry as `source: manual`. The category must be active and of the same type (an income cannot use `food`). `date` cannot be after the user\'s today: send `today` so the server knows it, otherwise it only blocks days that are in the future everywhere on Earth. Refetch the summary afterwards.',
        security: auth,
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['type', 'amount', 'category', 'date'],
            properties: {
              type: { type: 'string', enum: ['income', 'expense'] },
              amount: { type: 'integer', minimum: 1, description: 'Whole paise.' },
              category: { type: 'string' },
              note: { type: 'string', maxLength: 40 },
              date: { type: 'string', description: 'YYYY-MM-DD' },
              today: { type: 'string', description: 'The user\'s local day, YYYY-MM-DD. Used to refuse future dates.' },
            },
          },
          { type: 'expense', amount: 180000, category: 'food', note: 'DMart Ready', date: '2026-10-03', today: '2026-10-07' },
        ),
        responses: {
          201: okResponse('Transaction added', nullData, 'Transaction added'),
          400: err(
            'Amount not a whole number above 0, unknown category for the type, date in the future or not YYYY-MM-DD, or note over 40 characters',
            'Unknown category for this type',
          ),
          401: unauthorized,
          500: serverErr,
        },
      },
    },

    '/api/transactions/bulk': {
      post: {
        tags: ['Transactions'],
        summary: 'Save the entries ticked on the Smart add review screen',
        description:
          'Adds up to 80 entries at once. If any entry is invalid, none are saved. With `importId`, the entries are saved with the right `source` (`receipt`, `statement`, `voice` or `text`) and that Smart add run is marked `saved` with its `savedCount`. Sending the same `importId` again returns 409, which also stops a double tap from adding everything twice. Without `importId` the entries are saved as `manual`.',
        security: auth,
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['entries'],
            properties: {
              importId: { type: 'string', description: 'The `importId` returned by Smart add.' },
              today: { type: 'string', description: 'The user\'s local day, YYYY-MM-DD.' },
              entries: { type: 'array', minItems: 1, maxItems: 80, items: { $ref: '#/components/schemas/TransactionInput' } },
            },
          },
          {
            importId: '6abbdc841ea5e7ce727ac7',
            today: '2026-09-29',
            entries: [
              { type: 'expense', amount: 205000, category: 'shopping', note: 'Myntra', date: '2026-09-20' },
              { type: 'expense', amount: 184000, category: 'food', note: 'BigBasket', date: '2026-09-24' },
            ],
          },
        ),
        responses: {
          201: okResponse('Transactions added', nullData, '2 transactions added'),
          400: err('Empty or too long list, or any invalid entry (nothing is saved)', 'Unknown category for this type'),
          401: unauthorized,
          404: err('No Smart add run with this id for this user', 'Smart add run not found'),
          409: err('This run was already saved', 'This Smart add run was already saved'),
          500: serverErr,
        },
      },
    },

    '/api/transactions/{id}': {
      delete: {
        tags: ['Transactions'],
        summary: 'Delete one transaction (History)',
        description: 'Only deletes an entry that belongs to the logged-in user. There is no edit: delete it and add it again.',
        security: auth,
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', example: '6abde240bc24b8213063b0e3' } }],
        responses: {
          200: okResponse('Transaction deleted', nullData, 'Transaction deleted'),
          400: err('The id is not a valid id', 'Invalid _id'),
          401: unauthorized,
          404: err('No such transaction for this user', 'Transaction not found'),
          500: serverErr,
        },
      },
    },

    '/api/goals': {
      get: {
        tags: ['Goals'],
        summary: 'List goals with totals (Savings screen)',
        description:
          'Goals oldest first, each with its money log. `totalSaved` is the sum of `savedAmount`; `thisMonth` is the net money put aside in `month` (Take out counts as negative).',
        security: auth,
        parameters: [{ name: 'month', in: 'query', schema: { type: 'string', example: '2026-10' }, description: 'YYYY-MM. Defaults to the current month.' }],
        responses: {
          200: okResponse(
            'Goals',
            {
              type: 'object',
              properties: {
                goals: { type: 'array', items: { $ref: '#/components/schemas/Goal' } },
                totalSaved: { type: 'integer', description: 'Paise.' },
                thisMonth: { type: 'integer', description: 'Paise.' },
              },
            },
            'OK',
          ),
          400: err('month is not YYYY-MM', 'month must be YYYY-MM'),
          401: unauthorized,
          500: serverErr,
        },
      },
      post: {
        tags: ['Goals'],
        summary: 'Create a goal (New goal sheet)',
        security: auth,
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['name', 'targetAmount', 'targetMonth'],
            properties: {
              name: { type: 'string', maxLength: 28, example: 'Goa trip' },
              icon: { type: 'string', enum: ['shield', 'phone', 'plane', 'house', 'gift', 'star'], default: 'star' },
              targetAmount: { type: 'integer', minimum: 100, description: 'Paise.' },
              targetMonth: { type: 'string', example: '2027-03' },
            },
          },
          { name: 'Goa trip', icon: 'plane', targetAmount: 2000000, targetMonth: '2027-03' },
        ),
        responses: {
          201: okResponse('Goal created', nullData, 'Goal created'),
          400: err('Missing or invalid field', 'targetMonth must be YYYY-MM'),
          401: unauthorized,
          409: err('The user already has a goal with this name', 'You already have a goal with this name'),
          500: serverErr,
        },
      },
    },

    '/api/goals/{id}/contributions': {
      post: {
        tags: ['Goals'],
        summary: 'Add money or Take out',
        description:
          'A positive `amount` adds money, a negative one takes it out. `data` is null; call `GET /api/goals` to read the updated goal. The server recalculates `savedAmount` and sets `reachedAt` the first time the target is reached (the "Goal reached!" toast can be shown when `reachedAt` becomes set), clearing it if money is taken out again. Taking out more than is saved is refused.',
        security: auth,
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', example: '6a1da848f11b7e3f2d5ee904' } }],
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['amount', 'date'],
            properties: {
              amount: { type: 'integer', description: 'Whole paise, not 0. Negative = Take out.', example: 300000 },
              date: { type: 'string', description: 'YYYY-MM-DD. Cannot be after the user\'s today.', example: '2026-10-02' },
              today: { type: 'string', description: 'The user\'s local day, YYYY-MM-DD.' },
            },
          },
          { amount: 300000, date: '2026-10-02', today: '2026-10-02' },
        ),
        responses: {
          201: okResponse('Contribution saved', nullData, 'Money added'),
          400: err('Invalid amount or date, or more taken out than is saved', 'Cannot take out more than is saved'),
          401: unauthorized,
          404: err('No such goal for this user', 'Goal not found'),
          500: serverErr,
        },
      },
    },

    '/api/goals/{id}': {
      delete: {
        tags: ['Goals'],
        summary: 'Delete a goal and its money log',
        security: auth,
        parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'string', example: '6a1da848f11b7e3f2d5ee904' } }],
        responses: {
          200: okResponse('Goal deleted', nullData, 'Goal deleted'),
          400: err('The id is not a valid id', 'Invalid _id'),
          401: unauthorized,
          404: err('No such goal for this user', 'Goal not found'),
          500: serverErr,
        },
      },
    },

    '/api/users/me/data': {
      delete: {
        tags: ['Users'],
        summary: 'Start fresh / Clear all',
        description:
          'Deletes the user\'s transactions and goals and sets `hasExampleData` to false. The account, name, monthly budget, category limits and settings stay.',
        security: auth,
        responses: {
          200: okResponse('Data cleared', nullData, 'All data cleared'),
          401: unauthorized,
          500: serverErr,
        },
      },
    },

    '/api/smart-add': {
      post: {
        tags: ['Smart add'],
        summary: 'Read a bill photo, PDF, voice note or typed text into entries to review',
        description:
          '**Photo (`image`) and PDF (`pdf`):** either attach the file as a `file` form field (`multipart/form-data`, max 4 MB) or send it as base64 in `file` (JSON); the server has AI read it. **Voice and typed text (`voice`, `text`):** the app turns speech into text with its own speech-to-text package and sends `text`; typed notes go the same way. Typed and spoken text falls back to a keyword parser if AI is down (`parser: "rules"`); photos and PDFs need AI (502 if it cannot be reached, 422 if no amount was found). One call does everything: it saves an `aiimports` run and adds every entry found to `transactions` (amounts are stored in whole paise, so a bill of ₹2,050 is saved as `205000`; `source` is `receipt`, `statement`, `voice` or `text`). `data` is null; call `GET /api/transactions` to list the new entries. Photos and PDFs must stay under about 3 MB (Vercel body limit). Limited to 30 runs per user per day (429).',
        security: auth,
        requestBody: jsonBody(
          {
            type: 'object',
            required: ['inputType', 'today'],
            properties: {
              inputType: { type: 'string', enum: ['text', 'voice', 'image', 'pdf'], example: 'image' },
              text: { type: 'string', maxLength: 20000, description: 'Required for `text` and `voice`.', example: 'metro card recharge 1200' },
              file: {
                type: 'object',
                description: 'Required for `image` and `pdf`.',
                properties: {
                  mimeType: { type: 'string', enum: ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif', 'application/pdf'], example: 'image/jpeg' },
                  data: { type: 'string', description: 'The file, base64 encoded (no `data:` prefix).' },
                },
              },
              today: { type: 'string', description: 'The user\'s local day, YYYY-MM-DD.', example: '2026-10-05' },
              tzOffsetMinutes: { type: 'integer', description: 'Minutes ahead of UTC (IST = 330). Used to count today\'s runs for the daily limit. Defaults to 0.', example: 330 },
            },
          },
          { inputType: 'image', file: { mimeType: 'image/jpeg', data: '<base64>' }, today: '2026-10-05', tzOffsetMinutes: 330 },
        ),
        responses: {
          201: okResponse('Entries read and added to transactions', nullData, '2 transactions added'),
          400: err('Missing or invalid field', 'inputType must be text, voice, image or pdf'),
          413: err('The photo or PDF is too large', 'File is too large. Keep it under about 3 MB.'),
          401: unauthorized,
          422: err('No amount was found (the run is saved as failed)', 'Could not find any amount. Try adding it manually.'),
          502: err('A photo or PDF could not be read because the AI could not be reached', 'Could not read the file right now. Try again, or add it manually.'),
          429: err('The daily Smart add limit was reached', 'Daily Smart add limit reached. Try again tomorrow.'),
          500: serverErr,
        },
      },
    },
  },
};

// Same endpoint, with the photo or PDF attached as a normal file instead of base64.
module.exports.paths['/api/smart-add'].post.requestBody.content['multipart/form-data'] = { schema: multipartSmartAdd };

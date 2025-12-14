const Joi = require('joi');

const validateInput = {
  register: (data) => {
    const schema = Joi.object({
      username: Joi.string()
        .alphanum()
        .min(3)
        .max(30)
        .required()
        .messages({
          'string.alphanum': 'Username must contain only letters and numbers',
          'string.min': 'Username must be at least 3 characters long',
          'string.max': 'Username cannot exceed 30 characters'
        }),
      
      email: Joi.string()
        .email()
        .required()
        .messages({
          'string.email': 'Please provide a valid email address'
        }),
      
      password: Joi.string()
        .min(8)
        .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])'))
        .required()
        .messages({
          'string.min': 'Password must be at least 8 characters long',
          'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'
        }),
      
      fullName: Joi.string()
        .min(2)
        .max(50)
        .required()
        .messages({
          'string.min': 'Full name must be at least 2 characters long',
          'string.max': 'Full name cannot exceed 50 characters'
        }),
      
      phone: Joi.string()
        .pattern(new RegExp('^[+]?[1-9]\\d{1,14}$'))
        .optional()
        .messages({
          'string.pattern.base': 'Please provide a valid phone number'
        }),
      
      dateOfBirth: Joi.date()
        .max('now')
        .min('1900-01-01')
        .optional()
        .messages({
          'date.max': 'Date of birth cannot be in the future',
          'date.min': 'Please provide a valid date of birth'
        }),
      
      termsAccepted: Joi.boolean()
        .valid(true)
        .required()
        .messages({
          'any.only': 'You must accept the terms and conditions'
        })
    });

    return schema.validate(data, { abortEarly: false });
  },

  login: (data) => {
    const schema = Joi.object({
      identifier: Joi.string()
        .required()
        .messages({
          'any.required': 'Email, username, or phone number is required'
        }),
      
      password: Joi.string()
        .required()
        .messages({
          'any.required': 'Password is required'
        }),
      
      twoFactorCode: Joi.string()
        .length(6)
        .pattern(/^[0-9]+$/)
        .optional()
        .messages({
          'string.length': 'Two-factor code must be 6 digits',
          'string.pattern.base': 'Two-factor code must contain only numbers'
        }),
      
      deviceId: Joi.string().optional(),
      rememberMe: Joi.boolean().optional()
    });

    return schema.validate(data, { abortEarly: false });
  },

  forgotPassword: (data) => {
    const schema = Joi.object({
      identifier: Joi.string()
        .required()
        .messages({
          'any.required': 'Email, username, or phone number is required'
        })
    });

    return schema.validate(data, { abortEarly: false });
  },

  resetPassword: (data) => {
    const schema = Joi.object({
      token: Joi.string()
        .required()
        .messages({
          'any.required': 'Reset token is required'
        }),
      
      password: Joi.string()
        .min(8)
        .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])'))
        .required()
        .messages({
          'string.min': 'Password must be at least 8 characters long',
          'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'
        }),
      
      confirmPassword: Joi.string()
        .valid(Joi.ref('password'))
        .required()
        .messages({
          'any.only': 'Passwords do not match'
        })
    });

    return schema.validate(data, { abortEarly: false });
  },

  changePassword: (data) => {
    const schema = Joi.object({
      currentPassword: Joi.string()
        .required()
        .messages({
          'any.required': 'Current password is required'
        }),
      
      newPassword: Joi.string()
        .min(8)
        .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])'))
        .required()
        .messages({
          'string.min': 'Password must be at least 8 characters long',
          'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'
        }),
      
      confirmPassword: Joi.string()
        .valid(Joi.ref('newPassword'))
        .required()
        .messages({
          'any.only': 'Passwords do not match'
        })
    });

    return schema.validate(data, { abortEarly: false });
  },

  updateProfile: (data) => {
    const schema = Joi.object({
      fullName: Joi.string()
        .min(2)
        .max(50)
        .optional(),
      
      bio: Joi.string()
        .max(150)
        .optional(),
      
      website: Joi.string()
        .uri()
        .optional(),
      
      dateOfBirth: Joi.date()
        .max('now')
        .min('1900-01-01')
        .optional(),
      
      gender: Joi.string()
        .valid('male', 'female', 'other', 'prefer_not_to_say')
        .optional(),
      
      phone: Joi.string()
        .pattern(new RegExp('^[+]?[1-9]\\d{1,14}$'))
        .optional(),
      
      location: Joi.object({
        country: Joi.string().optional(),
        city: Joi.string().optional(),
        timezone: Joi.string().optional()
      }).optional(),
      
      language: Joi.string()
        .valid('en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'ja', 'ko', 'zh')
        .optional(),
      
      theme: Joi.string()
        .valid('light', 'dark', 'auto')
        .optional()
    });

    return schema.validate(data, { abortEarly: false });
  },

  updatePrivacySettings: (data) => {
    const schema = Joi.object({
      profileVisibility: Joi.string()
        .valid('public', 'private', 'friends')
        .optional(),
      
      showOnlineStatus: Joi.boolean().optional(),
      allowMessageRequests: Joi.boolean().optional(),
      showActivityStatus: Joi.boolean().optional(),
      
      allowTagging: Joi.string()
        .valid('everyone', 'friends', 'none')
        .optional(),
      
      allowStoryResharing: Joi.boolean().optional(),
      showInSuggestions: Joi.boolean().optional()
    });

    return schema.validate(data, { abortEarly: false });
  },

  updateNotificationSettings: (data) => {
    const schema = Joi.object({
      push: Joi.boolean().optional(),
      email: Joi.boolean().optional(),
      sms: Joi.boolean().optional(),
      likes: Joi.boolean().optional(),
      comments: Joi.boolean().optional(),
      follows: Joi.boolean().optional(),
      mentions: Joi.boolean().optional(),
      directMessages: Joi.boolean().optional(),
      liveVideos: Joi.boolean().optional(),
      reminders: Joi.boolean().optional()
    });

    return schema.validate(data, { abortEarly: false });
  },

  updateTimeLimit: (data) => {
    const schema = Joi.object({
      dailyLimit: Joi.number()
        .min(0)
        .max(1440) // 24 hours in minutes
        .optional(),
      
      breakReminders: Joi.boolean().optional(),
      
      sleepMode: Joi.object({
        enabled: Joi.boolean().optional(),
        startTime: Joi.string()
          .pattern(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
          .optional(),
        endTime: Joi.string()
          .pattern(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/)
          .optional()
      }).optional(),
      
      weeklyReport: Joi.boolean().optional()
    });

    return schema.validate(data, { abortEarly: false });
  },

  verifyEmail: (data) => {
    const schema = Joi.object({
      token: Joi.string()
        .required()
        .messages({
          'any.required': 'Verification token is required'
        })
    });

    return schema.validate(data, { abortEarly: false });
  },

  verifyPhone: (data) => {
    const schema = Joi.object({
      code: Joi.string()
        .length(6)
        .pattern(/^[0-9]+$/)
        .required()
        .messages({
          'string.length': 'Verification code must be 6 digits',
          'string.pattern.base': 'Verification code must contain only numbers'
        })
    });

    return schema.validate(data, { abortEarly: false });
  },

  twoFactorSetup: (data) => {
    const schema = Joi.object({
      method: Joi.string()
        .valid('app', 'sms', 'email')
        .optional()
        .default('app')
    });

    return schema.validate(data, { abortEarly: false });
  },

  twoFactorVerify: (data) => {
    const schema = Joi.object({
      code: Joi.string()
        .required()
        .messages({
          'any.required': 'Verification code is required'
        })
    });

    return schema.validate(data, { abortEarly: false });
  },

  twoFactorDisable: (data) => {
    const schema = Joi.object({
      password: Joi.string()
        .required()
        .messages({
          'any.required': 'Password is required'
        }),
      
      code: Joi.string()
        .required()
        .messages({
          'any.required': 'Two-factor code is required'
        })
    });

    return schema.validate(data, { abortEarly: false });
  }
};

module.exports = { validateInput };